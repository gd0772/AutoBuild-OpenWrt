<?php 
/*
* @link http://kodcloud.com/
* @author warlee | e-mail:kodcloud@qq.com
* @copyright warlee 2014.(Shanghai)Co.,Ltd
* @license http://kodcloud.com/tools/license/license.txt
*/

class explorerShare extends Controller{
	private $model;
	function __construct(){
		parent::__construct();
		$this->model  = Model('Share');
		$notCheck = array('link','file','pathParse');
		// 检测并处理分享信息
		if( equal_not_case(ST,'share') && 
			!in_array_not_case(ACT,$notCheck) ){
			$shareID = $this->parseShareID();
			$this->initShare($shareID);
			if(equal_not_case(MOD.'.'.ST,'explorer.share')){
				$this->authCheck();
			}
		}
	}

	// 自动解析分享id; 通过path或多选时dataArr;
	private function parseShareID(){
		$shareID = $this->in['shareID'];
		if($shareID) return $shareID;
		$thePath = $this->in['path'];
		if(!$thePath && isset($this->in['dataArr'])){
			$fileList = json_decode($this->in['dataArr'],true);
			$thePath  = $fileList[0]['path'];
		}
		$parse = KodIO::parse($thePath);
		if($parse['type'] == KodIO::KOD_SHARE_LINK){
			$shareID = $parse['id'];
		}
		return $shareID;
	}

	// 通用生成外链
	public function link($path){
		if(!$path || !$info = IO::info($path)) return;
		$pass = Model('SystemOption')->get('systemPassword');
		$hash = Mcrypt::encode($info['path'],$pass);
		return app_host_get()."explorer/share/file&hash={$hash}&name=".rawurlencode($info['name']);
	}
	public function linkFile($file){
		$pass = Model('SystemOption')->get('systemPassword');
		$hash = Mcrypt::encode($file,$pass,false,'kodcloud');
		return app_host_get()."explorer/share/file&hash={$hash}";
	}
	
	public function linkOut($path,$token=false){
		$parse  = KodIO::parse($path);
		if($parse['type'] == KodIO::KOD_SHARE_LINK){
			$url = app_host_get() . "explorer/share/fileOut&path=".rawurlencode($path);
		}else{
			$url = app_host_get() . "explorer/index/fileOut&path=".rawurlencode($path);
		}
		if($token) $url .= '&accessToken='.Action('user.index')->accessToken();
		return $url;
	}
	
	public function file(){
		if(!$this->in['hash']) return;
		$pass = Model('SystemOption')->get('systemPassword');
		$path = Mcrypt::decode($this->in['hash'],$pass);
		if(!$path){
			show_json(LNG('common.pathNotExists'),false);
		}
		$isDownload = isset($this->in['download']) && $this->in['download'] == 1;
		$downFilename = !empty($this->in['downFilename']) ? $this->in['downFilename'] : false;
		IO::fileOut($path,$isDownload,$downFilename);
	}
	
	/**
	 * 其他业务通过分享路径获取文档真实路径; 文件打开构造的路径 hash/xxx/xxx; 
	 * 解析路径,检测分享存在,过期时间,下载次数,密码检测;
	 */
	public function sharePathInfo($path,$encode=false){
		$parse = KodIO::parse($path);
		if(!$parse || $parse['type'] != KodIO::KOD_SHARE_LINK){
			return false;
		}
		$check = ActionCallHook('explorer.share.initShare',$parse['id']);
		if(is_array($check)){
			$GLOBALS['explorer.sharePathInfo.error'] = $check['data'];
			return false; // 不存在,时间过期,下载次数超出,需要登录,需要密码;
		} 
		if($this->share['options']['notView'] == '1'){//
			return false;
		}

		$truePath = $this->parsePath($path);
		$result = IO::infoWithChildren($truePath);
		if(is_array($result)){
			if($encode){
				$result = $this->itemInfo($result);
			}
			$result['shareID'] = $this->share['shareID'];
			$result['option']  = $this->share['options'];
		}
		return $result;
	}

	/**
	 * 通过分享hash获取分享信息；
	 * 提交分享密码
	 */
	public function get($get=false){
		$field = array(
			'shareHash','title','isLink','timeTo','numView','numDownload',
			'options','createTime','sourceInfo',
		);
		$data  = array_field_key($this->share,$field);
		$data['shareUser']  = Model("User")->getInfoSimpleOuter($this->share['userID']);
		$data['shareUser']  = $this->filterUserInfo($data['shareUser']);
		$data['sourceInfo'] = $this->itemInfo($data['sourceInfo']);
		if($get) return $data;
		show_json($data);
	}
	
	/**
	 * 分享信息初始化；
	 * 拦截相关逻辑
	 * 
	 * 过期拦截
	 * 下载次数限制拦截
	 * 登录用户拦截
	 * 密码检测拦截：如果参数有密码则检测并存储；错误则提示 
	 * 下载次数，预览次数记录
	 */
	public function initShare($hash=''){
		if($this->share) return;
		$this->share = $share = $this->model->getInfoByHash($hash);
		if(!$share || $share['isLink'] != '1'){
			show_json(LNG('explorer.share.notExist'),30100);
		}
		if($share['sourceInfo']['isDelete'] == '1'){
			show_json(LNG('explorer.share.notExist'),30100);
		}
		
		//检测是否过期
		if($share['timeTo'] && $share['timeTo'] < time()){
			show_json(LNG('explorer.share.expiredTips'),30101,$this->get(true));
		}

		//检测下载次数限制
		if( $share['options'] && 
			$share['options']['downloadNumber'] && 
			$share['options']['downloadNumber'] <= $share['numDownload'] ){
			$msg = LNG('explorer.share.downExceedTips');
			$pathInfo = explode('/', $this->in['path']);
			if(!empty($pathInfo[1]) || is_ajax()) {
				show_json($msg,30102,$this->get(true));
			}
			show_tips($msg);
		}
		//检测是否需要登录
		$user = Session::get("kodUser");
		if( $share['options'] && 
			$share['options']['onlyLogin'] == '1' && 
			!is_array($user)){
			show_json(LNG('explorer.share.loginTips'),30103,$this->get(true));
		}
		//检测密码
		$passKey  = 'Share_password_'.$share['shareID'];
		if( $share['password'] ){
			if( isset($this->in['password']) ){
				$code = md5(BASIC_PATH.Model('SystemOption')->get('systemPassword'));
				$pass = Mcrypt::decode(trim($this->in['password']),md5($code));
				
				if($pass == $share['password']){
					Session::set($passKey,$pass);
				}else{
					show_json(LNG('explorer.share.errorPwd'),false);
				}
			}
			// 检测密码
			if( Session::get($passKey) != $share['password'] ){
				show_json(LNG('explorer.share.needPwd'),30104,$this->get(true));
			}
		}
	}

	/**
	 * 权限检测
	 * 下载次数，预览次数记录
	 */
	private function authCheck(){
		$share = $this->share;
		$where = array("shareID"=>$share['shareID']);
		if( equal_not_case(ACT,'get') ){
			$this->model->where($where)->setAdd('numView');
		}
		//权限检测；是否允许下载、预览、上传;
		if( $share['options'] && 
			$share['options']['notDownload'] == '1' && 
			((equal_not_case(ACT,'fileOut') && $this->in['download']=='1') || 
			equal_not_case(ACT,'zipDownload')) ){
			show_json(LNG('explorer.share.noDownTips'),false);
		}
		if( $share['options'] && 
			$share['options']['notView'] == '1' && 
			(	equal_not_case(ACT,'fileGet') ||
				equal_not_case(ACT,'fileOut')
			)
		){
			show_json(LNG('explorer.share.noViewTips'),false);
		}
		if( $share['options'] && 
			$share['options']['canUpload'] != '1' && 
			equal_not_case(ACT,'fileUpload') ){
			show_json(LNG('explorer.share.noUploadTips'),false);
		}
		if((equal_not_case(ACT,'fileOut') && $this->in['download']=='1') ||
			equal_not_case(ACT,'zipDownload') || 
			equal_not_case(ACT,'fileDownload')){
			$this->model->where($where)->setAdd('numDownload');
		}
	}
	/**
	 * 检测并获取真实路径;
	 */
	private function parsePath($path){
		$rootSource = $this->share['sourceInfo']['path'];
		$parse = KodIO::parse($path);
		if(!$parse || $parse['type']  != KodIO::KOD_SHARE_LINK ||
			$this->share['shareHash'] != $parse['id'] ){
			show_json(LNG('explorer.dataError'),false);
		}
		
		$pathInfo = IO::infoFull($rootSource.$parse['param']);
		if(!$pathInfo){
			show_json(LNG('explorer.pathError'),false);
		}
		return $pathInfo['path'];
	}
	
	public function pathInfo(){
		$fileList = json_decode($this->in['dataArr'],true);
		if(!$fileList) show_json(LNG('explorer.error'),false);

		if(count($fileList) == 1){
			$path 	= $this->parsePath($fileList[0]['path']);
			$data 	= $this->itemInfo(IO::infoWithChildren($path));
			show_json($data);
		}
		$result = array();
		for ($i=0; $i < count($fileList); $i++) {
			$path 	= $this->parsePath($fileList[$i]['path']);
			$result[] = $this->itemInfo(IO::infoWithChildren($path));
		}
		show_json($result);		
	}

	//输出文件
	public function fileOut(){
		$path = rawurldecode($this->in['path']);//允许中文空格等;
		if(request_url_safe($path)) {
			header('Location:' . $path);exit;
		} 
		$path = $this->parsePath($path);
		$isDownload = $this->in['download'] == 1;
		IO::fileOut($path,$isDownload);
	}
	public function fileDownload(){
		$this->in['download'] = 1;
		$this->fileOut();
	}
	
	public function fileUpload(){
		$this->in['path'] = $this->parsePath($this->in['path']);
		Action("explorer.upload")->fileUpload();
	}
	public function fileGet(){
		$this->in['path'] = $this->parsePath($this->in['path']);
		$this->in['pageNum'] = 1024 * 1024 * 10;
		$result = ActionCallHook("explorer.editor.fileGet");
		if($result['code']){
			$result['data'] = $this->itemInfo($result['data']);
		}
		show_json($result['data'],$result['code'],$result['info']);
	}
	
	public function pathList(){
		$pathInfo = KodIO::parse($this->in['path']);
		if($pathInfo['type'] == KodIO::KOD_SEARCH){
			return $this->pathSearch($pathInfo);
		}
		
		$path = $this->parsePath($this->in['path']);
		$data = IO::listPath($path);
		$this->dataParseOexe($data['fileList']);
		$this->dataParse($data,$path);
		show_json($data);
	}
	private function pathSearch($pathInfo){
		$pathInfo['param'] = trim($pathInfo['param'],'/');
		$search = ActionCall('explorer.listSearch.parseSearch',$pathInfo['param']);
		$param = array(
			'words' 	=> $search['words'],
			'parentID'	=> $this->share['sourceID'],
		);
		$data = Model("Source")->listSearch($param);
		$this->dataParseOexe($data['fileList']);
		$this->dataParse($data,$this->in['path']);
		$data['current'] = false;
		$data['searchParam'] = $search;
		show_json($data);
	}
	
	private function dataParseOexe(&$list){
		$maxSize = 1024*1024*2;
		$index = 0;
		$maxLoad = 50;	//获取内容上限；
		if(count($list) >= 100){ //当列表过多时，获取少量应用内容；
			$maxLoad = 5;
		}
		foreach ($list as &$item) {
			if( $item['ext'] != 'oexe' || $item['size'] > $maxSize){
				continue;
			}
			if($index++ >= $maxLoad) break;
			$content = IO::getContent($item['path']);
			$item['oexeContent'] = json_decode($content);
		}
	}

	/**
	 * 分享压缩下载
	 * 压缩和下载合并为同一方法
	 * @return void
	 */
	public function zipDownload(){
		//禁用分享文件夹压缩;
		return show_json(LNG('explorer.share.actionNotSupport'),false);
		
		if($path = Input::get('path',null,null)){
			$path = Action('explorer.index')->pathCrypt($path,false);
			if(!$path || !IO::exist($path)) {
				show_json(LNG('common.pathNotExists'), false);
			}
			IO::fileOut($path, 1);
			return del_dir(get_path_father($path));
		}
		// 压缩
		$dataArr = json_decode($this->in['dataArr'],true);
		foreach($dataArr as $i => $item){
			$dataArr[$i]['path'] = $this->parsePath($item['path']);
		}
		$this->in = array('dataArr'	=> json_encode($dataArr));
		Action('explorer.index')->zipDownload();
	}

	/**
	 * 递归处理数据；自动加入打开等信息
	 * 如果是纯数组: 处理成 {folderList:[],fileList:[],thisPath:xxx,current:''}
	 */
	private function dataParse(&$data,$path){
		$data['current']  = IO::info($path,false);
		$data['thisPath'] = $this->in['path'];
		$data['targetSpace'] = Action('explorer.list')->targetSpace($data['current']);
		foreach ($data as $key =>&$listData) {
			if($key == 'current'){
				$listData = $this->itemInfo($listData);
			}
			if($key == 'fileList' || $key == 'folderList'){
				foreach ($listData as &$item) {
					$item = $this->itemInfo($item);
				}
			}
		}
	}

	public function itemInfo($item){
		$rootPath = $this->share['sourceInfo']['pathDisplay'];
		// 物理路径,io路径;
		if($this->share['sourceID'] == '0'){
			$rootPath = KodIO::clear($this->share['sourcePath']);
		}
		$item['pathDisplay'] = $item['pathDisplay'] ? $item['pathDisplay']:$item['path'];

		$field = array(
			'name','path','type','size','ext',
			'createUser','modifyUser','createTime','modifyTime','sourceID',
			'hasFolder','hasFile','children','targetType','targetID','pageInfo',
			'base64','content','charset','oexeContent',
		);
		$theItem = array_field_key($item,$field);
		$path 	 = KodIO::makePath(KodIO::KOD_SHARE_LINK,$this->share['shareHash']);
		$name    = $this->share['sourceInfo']['name'];
		$theItem['pathDisplay'] = ltrim(substr($item['pathDisplay'],strlen($rootPath)),'/');
		$theItem['path'] = rtrim($path,'/').'/'.$theItem['pathDisplay'];
		$theItem['pathDisplay'] = $name.'/'.$theItem['pathDisplay'];

		if($theItem['type'] == 'folder'){
			$theItem['ext'] = 'folder';
		}
		$theItem['targetType'] = 'folder';
		if(is_array($theItem['createUser'])) $theItem['createUser'] = $this->filterUserInfo($theItem['createUser']);
		if(is_array($theItem['modifyUser'])) $theItem['modifyUser'] = $this->filterUserInfo($theItem['modifyUser']);
		return $theItem;
	}
	private function filterUserInfo($userInfo){
		$name = !empty($userInfo['nickName']) ? $userInfo['nickName'] : $userInfo['name'];
		unset($userInfo['nickName'], $userInfo['name']);
		$userInfo['nameDisplay'] = $this->parseName($name);
		return $userInfo;
	}
	private function parseName($name){
		$len = mb_strlen($name);
		if($len > 3) {
			$len = ($len > 5 ? 5 : $len) - 2;
			$name = mb_substr($name, 0, 2) . str_repeat('*', $len);	// AA***
		}else{
			$name = mb_substr($name, 0, 1) . str_repeat('*', $len - 1);	// A**
		}
		return $name;
	}

	/**
	 * 分享文件举报
	 * @return void
	 */
	public function report(){
		$data = Input::getArray(array(
			'path'	=> array('check' => 'require'),
			'type'	=> array('check' => 'in', 'param' => array('1','2','3','4','5')),
			'desc'	=> array('default' => '')
		));
		$fileID = 0;
		if($this->share['sourceInfo']['type'] == 'file') {
			$info = $this->sharePathInfo($data['path']);
			$fileID = $info['fileInfo']['fileID'];
		}
		$data['shareID']	= $this->share['shareID'];
		$data['sourceID']	= $this->share['sourceID'];
		$data['title']		= $this->share['title'];
		$data['fileID']		= $fileID;
		$res = $this->model->reportAdd($data);
		show_json('OK', !!$res);
	}
}