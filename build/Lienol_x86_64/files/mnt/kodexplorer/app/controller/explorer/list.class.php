<?php
/*
* @link http://kodcloud.com/
* @author warlee | e-mail:kodcloud@qq.com
* @copyright warlee 2014.(Shanghai)Co.,Ltd
* @license http://kodcloud.com/tools/license/license.txt
*/

/**
 * 文件列表通用入口获取
 * 
 * 逻辑参数
 * listTypeSet 		// 指定列表模式; icon,list,split
 * disableSort 		// 是否禁用排序; 0,1
 */
class explorerList extends Controller{
	private $model;
	public function __construct(){
		parent::__construct();
		$this->model = Model("Source");
	}	
	public function path($thePath = false){
		$path     = $thePath ? $thePath : $this->in['path'];
		$path     = $path != '/' ? rtrim($path,'/') : '/';//路径保持统一;
		$path 	  = $this->checkDesktop($path);
		$pathParse= KodIO::parse($path);
		$id 	  = $pathParse['id'];
		switch($pathParse['type']){
			case KodIO::KOD_USER_FAV:			$data = Action('explorer.fav')->get();break;
			case KodIO::KOD_USER_RECYCLE:		$data = $this->model->listUserRecycle();break;
			case KodIO::KOD_USER_FILE_TAG:		$data = $this->model->listUserTag($id);break;
			case KodIO::KOD_USER_FILE_TYPE:		$data = $this->model->listPathType($id);break;
			case KodIO::KOD_USER_RECENT:		$data = $this->listRecent();break;
			case KodIO::KOD_GROUP_ROOT_SELF:	$data = Action('explorer.listGroup')->groupSelf($pathParse);break;
			case KodIO::KOD_USER_SHARE:			$data = Action('explorer.userShare')->myShare('to');break;
			case KodIO::KOD_USER_SHARE_LINK:	$data = Action('explorer.userShare')->myShare('link');break;
			
			case KodIO::KOD_USER_SHARE_TO_ME:	$data = Action('explorer.userShare')->shareToMe($id);break;
			case KodIO::KOD_SHARE_ITEM:			$data = Action('explorer.userShare')->sharePathList($pathParse);break;
			case KodIO::KOD_SHARE_LINK:			$data = Action('explorer.share')->pathList();break;
			case KodIO::KOD_SEARCH:				$data = Action('explorer.listSearch')->listSearch($pathParse);break;
			case KodIO::KOD_BLOCK:				$data = $this->blockChildren($id);break;
			case KodIO::KOD_SOURCE:				$data = IO::listPath($path);break;
			case KodIO::KOD_IO:					$data = IO::listPath($path);break;
			default:$data = IO::listPath($path);break;
		}
		$this->parseData($data,$path);
		$data = Hook::filter('explorer.list.path.parse',$data);

		if($thePath) return $data;
		show_json($data);
	}
	public function parseData(&$data,$path){
		$pathParse= KodIO::parse($path);
		$this->parseAuth($data,$path);
		$this->checkExist($data,$pathParse);
		$this->pageParse($data,$pathParse);
		$this->parseDataHidden($data);
		
		//回收站追加物理/io回收站;
		Action('explorer.recycleDriver')->appendList($data,$pathParse); 
		Action('explorer.listGroup')->appendChildren($data);
		
		$this->pathListParse($data);
		$this->pageReset($data);
	}	
	
	// 桌面文件夹自动检测;不存在处理;
	private function checkDesktop($path){
		if(trim($path,'/') !== trim(MY_DESKTOP,'/')) return $path;
		if(IO::info($path)) return MY_DESKTOP;//存在则不处理;
		
		$desktopName = LNG('explorer.toolbar.desktop');
		$model  = Model("Source");
		$find   = IO::fileNameExist(MY_HOME,$desktopName);
		$rootID = KodIO::sourceID(MY_HOME);
		if(!$find){
			$find = $model->mkdir($rootID,$desktopName);
		}
		$model->metaSet($find,'desktop','1');
		$model->metaSet($rootID,'desktopSource',$find);
		Model('User')->cacheFunctionClear('getInfo',USER_ID);
		return KodIO::make($find);
	}
	
	/**
	 * 最近文档；
	 * 仅限自己的文档；不分页；不支持排序；  最新修改时间 or 最新修改 or 最新打开 max top 100;
	 * 
	 * 最新自己创建的文件(上传or拷贝)
	 * 最新修改的，自己创建的文件	
	 * 最新打开的自己的文件 		
	 * 
	 * 资源去重；整体按时间排序【创建or上传  修改  打开】
	 */
	private function listRecent(){
		$list = array();
		$this->listRecentWith('createTime',$list);		//最近上传or创建
		$this->listRecentWith('modifyTime',$list);		//最后修改
		$this->listRecentWith('viewTime',$list);		//最后打开
		
		//合并重复出现的类型；
		foreach ($list as &$value) {
			$value['recentType'] = 'createTime';
			$value['recentTime'] = $value['createTime'];
			if($value['modifyTime'] > $value['recentTime']){
				$value['recentType'] = 'modifyTime';
				$value['recentTime'] = $value['modifyTime'];
			}
			if($value['viewTime'] > $value['recentTime']){
				$value['recentType'] = 'viewTime';
				$value['recentTime'] = $value['viewTime'];
			}
		}
		
		$list = array_sort_by($list,'recentTime',true);
		$listRecent = array_to_keyvalue($list,'sourceID');
		$result = array();
		if(!empty($listRecent)){
			$where  = array( 'sourceID'=>array('in',array_keys($listRecent)) );
			$result = $this->model->listSource($where);
		}
		$fileList = array_to_keyvalue($result['fileList'],'sourceID');
		// pr($fileList,$listRecent);exit;
		
		//保持排序，合并数据
		foreach ($fileList as $sourceID => &$value) {
			$item  = $listRecent[$sourceID];
			if(!$item){
				unset($fileList[$sourceID]);
				continue;
			}
			$value = array_merge($value,$item);
		}
		$result['fileList'] = array_values($fileList);
		$result['disableSort'] = 1;
		$result['listTypeSet'] = 'list';
		// unset($result['pageInfo']);
		return $result;
	}
	private function listRecentWith($timeType,&$result){
		$where = array(
			'targetType'	=> SourceModel::TYPE_USER,
			'targetID'		=> USER_ID,
			'isFolder'		=> 0,
			'isDelete'		=> 0,
			'createTime'	=> array('>',time() - 3600*24*60),//2个月内;
			'size'			=> array('>',0),
		);

		$maxNum = 50;	//最多150项
		$field  = 'sourceID,name,createTime,modifyTime,viewTime';
		$list   = $this->model->field($field)->where($where)
					->limit($maxNum)->order($timeType.' desc')->select();
		$list   = array_to_keyvalue($list,'sourceID');
		$result = array_merge($result,$list);
		$result = array_to_keyvalue($result,'sourceID');
	}

	private function pageParse(&$data){
		if(isset($data['pageInfo'])) return;
		$in = $this->in;
		$pageNumMax = 5000;
		$pageNum = isset($in['pageNum'])?$in['pageNum']: 3000;
		if($pageNum === -1){ // 不限分页情况; webdav列表处理;
			unset($in['pageNum']);
			$pageNumMax = 100000000;
			$pageNum = $pageNumMax;
		}
				
		$fileCount  = count($data['fileList']);
		$folderCount= count($data['folderList']);
		$totalNum	= $fileCount + $folderCount;
		$pageNum 	= intval($pageNum);
		$pageNum	= $pageNum <= 5 ? 5 : ($pageNum >= $pageNumMax ? $pageNumMax : $pageNum);
		$pageTotal	= ceil( $totalNum / $pageNum);
		$page		= intval( isset($in['page'])?$in['page']:1);
		$page		= $page <= 1 ? 1  : ($page >= $pageTotal ? $pageTotal : $page);
		$data['pageInfo'] = array(
			'totalNum'	=> $totalNum,
			'pageNum'	=> $pageNum,
			'page'		=> $page,
			'pageTotal'	=> $pageTotal,
		);
		if($pageTotal <= 1) return;

		$sort = $this->_parseOrder();
		$isDesc = $sort['desc'] == 'desc';
		$data['fileList'] 	= array_sort_by($data['fileList'],$sort['key'],$isDesc);
		$data['folderList'] = array_sort_by($data['folderList'],$sort['key'],$isDesc);
		
		$start = ($page-1) * $pageNum;
		$end   = $start + $pageNum;
		if( $end <= $folderCount){ // 文件夹范围内;
			$data['folderList'] = array_slice($data['folderList'],$start,$pageNum);
			$data['fileList'] 	= array();
		}else if($start >= $folderCount){ // 文件范围内;
			$data['folderList'] = array();
			$data['fileList'] 	= array_slice($data['fileList'],$start-$folderCount,$pageNum);
		}else{ // 各自占一部分;
			$folderNeed  = $folderCount - $start;
			$data['folderList'] = array_slice($data['folderList'],$start,$folderNeed);
			$data['fileList'] 	= array_slice($data['fileList'],0,$pageNum-($folderNeed) );
		}
	}
	private function pageReset(&$data){
		if(!isset($data['pageInfo'])) return;
		$group = isset($data['groupList']) ? count($data['groupList']) : 0;
		$total = count($data['fileList']) + count($data['folderList']) + $group;
		$pageInfo = $data['pageInfo'];
		if(	$pageInfo['page'] == 1 && $pageInfo['pageTotal'] == 1){
			$data['pageInfo']['totalNum'] = $total;
		}

		// 某一页因为权限全部过滤掉内容, 则加大每页获取条数;
		if(	$total == 0 && $pageInfo['totalNum'] != 0 && $pageInfo['pageTotal'] > 1 ){
			$this->in['pageNum'] = $pageInfo['pageNum'] * 2;
			if($this->in['pageNum'] < 500){
				$this->in['pageNum'] = 500;
			}
			$newData = $this->path($this->in['path']);
			show_json($newData);
		}
	}
	
	private function _parseOrder(){
		$defaultField = Model('UserOption')->get('listSortField');
		$defaultSort  = Model('UserOption')->get('listSortOrder');
		$sortTypeArr  = array('up'=>'asc','down'=>'desc');
		$sortFieldArr = array(
			'name'			=> 'name',
			'size'			=> 'size',
			'type'			=> 'ext',
			'ext'			=> 'fileType',
			'createTime'	=> 'createTime',
			'modifyTime'	=> 'modifyTime'
		);
		$sortField    = Input::get("sortField",'in',$defaultField,array_keys($sortFieldArr));
		$sortType	  = Input::get("sortType", 'in',$defaultSort,array_keys($sortTypeArr));
		if( !in_array($sortField,array_keys($sortFieldArr)) ){
			$sortField = 'name';
		}
		if( !in_array($sortType,array_keys($sortTypeArr)) ){
			$sortField = 'up';
		}
		return array('key'=>$sortFieldArr[$sortField],'desc'=>$sortTypeArr[$sortType]);
	}
	
	/**
	 * 检查目录是否存在;
	 */
	private function checkExist($data,$pathInfo){
		$exist = true;
		switch($pathInfo['type']){
			case KodIO::KOD_SOURCE:
				if($data['thisPath'] == '{source:0}/') return;
				$exist = !!$data['current'];
				if($exist && $data['current']['isDelete'] == '1'){
					show_json(LNG("explorer.pathInRecycle"),false);
				}
				break;
			case KodIO::KOD_SHARE_ITEM:
			case KodIO::KOD_IO:$exist = !!$data['current'];break;
			default:break;
		}
		if(!$exist){
			show_json(LNG('common.pathNotExists'),false);
		}
	}
	public function pathCurrent($path,$loadInfo = true){
		$info 	 = KodIO::parse($path);
		$driver  = IO::init($path);
		$current = false;
		if($loadInfo){
			$current = IO::info($path,false);
		}else if(!$driver){
			$current = array('exists'=>false,'type'=>'folder');
		}else if(!$info['type'] && $driver->getType() == 'local'){
			// 其他网络存储不在此获取信息; 收藏夹列表;
			$current = IO::info($path,false);
			if(!$current){ //不存在;
				$current = array('exists'=>false);
			}
		}
		$current = Model('SourceAuth')->authOwnerApply($current);
		// pr($loadInfo,$current,$path);exit;

		if(!$current){
			$current = $this->ioInfo($info['type']);
			if($info['type'] == KodIO::KOD_BLOCK){
				$list = $this->blockItems();
				$current = array(
					'name' 	=> $list[$info['id']]['name'],
					'icon'	=> 'block-item',
				);
				$current['name'] = $current['name'] ? $current['name']:'root';
			}else if($info['type'] == KodIO::KOD_USER_FILE_TYPE){
				$list = $this->blockFileType();
				$current = $list[$info['id']];
				$current['name'] = LNG('common.fileType').' - '.$current['name'];
			}else if($info['type'] == KodIO::KOD_USER_FILE_TAG){
				$list = Action('explorer.tag')->tagList();
				$current = $list[$info['id']];
				$current['name'] = LNG('common.tag').' - '.$current['name'];
			}else if($info['type'] == KodIO::KOD_SEARCH){
			}
		}
		$current['path'] = $path;
		return $current;
	}
	
	
	public function pathListParse(&$data){
		$timeNow = timeFloat();
		$timeMax = 1.5;
		$infoFull= true;
		$data['current'] = $this->pathInfoParse($data['current'],$data['current']);
		foreach ($data as $type =>$list) {
			if(!in_array($type,array('fileList','folderList','groupList'))) continue;
			foreach ($list as $key=>$item){
				if(timeFloat() - $timeNow >= $timeMax){$infoFull = false;}
				$data[$type][$key] = $this->pathInfoParse($item,$data['current'],$infoFull);
			}
		}
	}
	
	public function pathInfoParse($pathInfo,$current=false,$infoFull=true){
		$pathInfo = Action('explorer.fav')->favAppendItem($pathInfo);
		$pathInfo = Action('explorer.userShare')->shareAppendItem($pathInfo);
		$pathInfo = Action('explorer.listDriver')->parsePathIO($pathInfo,$current);
		$pathInfo = Action('explorer.listDriver')->parsePathChildren($pathInfo,$current);
		$pathInfo['pathDisplay'] = _get($pathInfo,'pathDisplay',$pathInfo['path']);

		// 下载权限处理;
		$pathInfo['canDownload'] = true;
		if(isset($pathInfo['auth'])){
			$authValue = $pathInfo['auth']['authValue'];
			$pathInfo['canDownload'] = Model('Auth')->authCheckDownload($authValue);
		}
		if($pathInfo['type'] == 'file' && $infoFull){
			$pathInfo = $this->pathParseOexe($pathInfo);
			$pathInfo = $this->pathInfoMore($pathInfo);
		}
		// 没有下载权限,不显示fileInfo信息;
		if(!$pathInfo['canDownload']){
			unset($pathInfo['fileInfo']);
			unset($pathInfo['hashMd5']);
		}
		if(isset($pathInfo['fileID'])){
			unset($pathInfo['fileID']);
		}
		if(isset($pathInfo['fileInfo']['path'])){
			unset($pathInfo['fileInfo']['path']);
		}
		$pathInfo = Hook::filter('explorer.list.itemParse',$pathInfo);
		return $pathInfo;
	}

	/**
	 * 递归处理数据；自动加入打开等信息
	 * 如果是纯数组: 处理成 {folderList:[],fileList:[],thisPath:xxx,current:''}
	 */
	private function parseAuth(&$data,$path){
		if( !isset($data['folderList']) || 
			!is_array($data['folderList'])
		) { //处理成统一格式
			$listTemp = isset($data['fileList']) ? $data['fileList'] : $data;
			$data = array(
				"folderList" 	=> $listTemp ? $listTemp : array(),
				'fileList'		=> array()
			);
		}
		$path = rtrim($path,'/').'/';
		$data['current']  = $this->pathCurrent($path);
		$data['thisPath'] = $path;
		$data['targetSpace'] = $this->targetSpace($data['current']);		
		foreach ($data['folderList'] as &$item) {
			if( isset($item['children']) ){
				$item['isParent'] = true;
				$this->parseAuth($item['children'],$item['path']);
			}
			$item['type'] = isset($item['type']) ? $item['type'] : 'folder';
		}
		//$item['auth']['authValue']=0; 权限检测 
		$data['fileList']   = $this->dataFilterAuth($data['fileList']);
		$data['folderList'] = $this->dataFilterAuth($data['folderList']);
	}
	
	// 显示隐藏文件处理; 默认不显示隐藏文件;
	private function parseDataHidden(&$data){
		if(Model('UserOption')->get('displayHideFile') == '1') return;
		$pathHidden = Model('SystemOption')->get('pathHidden');
		$pathHidden = explode(',',$pathHidden);
		$hideNumber = 0;
		
		$parse = KodIO::parse($data['current']['path']);
		if($parse['type'] == KodIO::KOD_USER_SHARE_TO_ME) return;
		foreach ($data as $type =>$list) {
			if(!in_array($type,array('fileList','folderList'))) continue;
			$result = array();
			foreach ($list as $item){
				if(substr($item['name'],0,1) == '.') continue;
				if(in_array($item['name'],$pathHidden)) continue;
				$result[] = $item;
			}
			$data[$type] = $result;
			$hideNumber  += count($list) - count($result);
		}
		// 总文件数; 只减去当前页;暂不处理多页情况;
		// if(is_array($data['pageInfo']) && $hideNumber > 0){
		// 	$data['pageInfo']['totalNum'] -= $hideNumber;
		// }
	}

	
	// 用户或部门空间尺寸;
	public function targetSpace($current){
		if(!_get($current,'targetID')) return false;
		if(	isset($current['auth']) &&
			$current['auth']['authValue'] == -1 ){
			return false;
		}
		if(!$current || !isset($current['targetType'])){
			$current = array("targetType"=>'user','targetID'=>USER_ID);//用户空间;
		}
		return Action('explorer.auth')->space($current['targetType'],$current['targetID']);
	}
	
	private function dataFilterAuth($list){
		if($GLOBALS['isRoot'] && $this->config["ADMIN_ALLOW_SOURCE"]) return $list;
		foreach ($list as $key => $item) {
			if( isset($item['targetType']) &&
				$item['targetType'] == 'user' &&
				$item['targetID'] == USER_ID ){
				continue;
			}
			if( isset($item['targetType']) && 
				(!$item['auth'] || $item['auth']['authValue'] == 0 ) // 不包含-1,构建通路;
			){
				unset($list[$key]);
			}
		}
		return array_values($list);
	}

	// 文件详细信息处理;
	public function pathInfoMore($pathInfo){
		//return $pathInfo;
		$infoKey  = 'fileInfoMore';
		$cacheKey = 'fileInfo.'.md5($pathInfo['path'].'@'.$pathInfo['size'].$pathInfo['modifyTime']);
		// unset($pathInfo[$infoKey]);Cache::remove($cacheKey); //不使用缓存;
		
		if(isset($pathInfo[$infoKey])){
		}else if(isset($pathInfo['sourceID'])){
			$fileID = _get($pathInfo,'fileInfo.fileID');
			GetInfo::infoAdd($pathInfo);
			if($fileID && is_array(_get($pathInfo,$infoKey) )){
				$value = json_encode($pathInfo[$infoKey]);
				Model("File")->metaSet($fileID,$infoKey,$value);
			}
		}else{ // 本地存储, io存储;
			$infoMore = Cache::get($cacheKey);
			if(is_array($infoMore)){
				$pathInfo[$infoKey] = $infoMore;
			}else{
				GetInfo::infoAdd($pathInfo);
				if(is_array(_get($pathInfo,$infoKey)) ){
					Cache::set($cacheKey,$pathInfo[$infoKey],3600*24*20);
				}
			}
		}
		// 文件封面;
		if(isset($pathInfo[$infoKey]) && isset($pathInfo[$infoKey]['fileThumb']) ){
			$fileThumb = $pathInfo[$infoKey]['fileThumb'];
			unset($pathInfo[$infoKey]['fileThumb']);
			$pathInfo['fileThumb'] = Action('explorer.share')->linkFile($fileThumb);
		}
		return $pathInfo;
	}
	
	/**
	 * 追加应用内容信息;
	 */
	private function pathParseOexe($pathInfo){
		$maxSize = 1024*1024*2;
		if($pathInfo['ext'] != 'oexe' || $pathInfo['size'] > $maxSize) return $pathInfo;

		$content = IO::getContent($pathInfo['path']);
		$pathInfo['oexeContent'] = json_decode($content,true);
		if( $pathInfo['oexeContent']['type'] == 'path' && 
			isset($pathInfo['oexeContent']['value']) ){
			$linkPath = $pathInfo['oexeContent']['value'];
			if(Action('explorer.auth')->fileCan($linkPath,'show')){
				$pathInfo['oexeSourceInfo'] = IO::info($linkPath);
			}
		}
		return $pathInfo;
	}
	/**
	 * 根数据块
	 */
	private function blockRoot(){
		$list = $this->blockItems();
		if(!$this->pathEnable('fileType')){unset($list['fileType']);}
		if(!$GLOBALS['isRoot'] || !$this->pathEnable('driver')){unset($list['driver']);}
		if(!$this->pathEnable('fileTag')){unset($list['fileTag']);}
		$result = array();
		foreach ($list as $type => $item) {
			$block = array(
				"name"		=> $item['name'],
				"path"		=> '{block:'.$type.'}/',
				"open"		=> $item['open'],
				"icon"		=> 'block-item',
				"isParent"	=> true,
				"children"	=> $this->blockChildren($type),
			);
			if($block['children'] === false) continue;
			$result[] = $block;
		}
		return $result;
	}
	private function blockItems(){
		$list = array(
			'files'		=>	array('name'=>LNG('common.position'),'open'=>true),
			'tools'		=>	array('name'=>LNG('common.tools'),'open'=>true,'children'=>true),
			'fileType'	=>	array('name'=>LNG('common.fileType'),'open'=>false,'children'=>true),
			'fileTag'	=>	array('name'=>LNG('common.tag'),'open'=>false,'children'=>true),
			'driver'	=>	array('name'=>LNG('common.mount').' (admin)','open'=>false),
		);
		return $list;
	}
	
	/**
	 * 数据块数据获取
	 */
	private function blockChildren($type){
		$result = array();
		switch($type){
			case 'root':		$result = $this->blockRoot();break; //根
			case 'files': 		$result = $this->blockFiles();break;
			case 'tools': 		$result = $this->blockTools();break;
			case 'fileType': 	$result = $this->blockFileType();break;
			case 'fileTag': 	$result = Action('explorer.tag')->tagList();break;
			case 'driver': 		$result = Action("explorer.listDriver")->get();break;
		}
		return array_values($result);
	}
	
	/**
	 * 文件位置
	 * 收藏夹、我的网盘、公共网盘、我所在的部门
	 */
	private function blockFiles(){
		$groupRoot = '1';
		$groupInfo = Model('Group')->getInfo($groupRoot);
		$list = array(
			"fav"=> $this->ioInfo(KodIO::KOD_USER_FAV),
			"my"=>array(
				'name'			=> LNG('explorer.toolbar.rootPath'),//我的网盘
				'path' 			=> KodIO::make(Session::get('kodUser.sourceInfo.sourceID')),
				'open'			=> true,
				"sourceRoot"	=> 'userSelf',//文档根目录标记；前端icon识别时用：用户，部门
				'targetType'	=> 'user',
				'targetID' 		=> USER_ID,
			),
			"rootGroup"=>array(
				'name'			=> $groupInfo['name'],//公共网盘
				'path' 			=> KodIO::make($groupInfo['sourceInfo']['sourceID']),
				"sourceRoot"	=> 'groupPublic',
				'targetType'	=> 'group',
				'targetID' 		=> $groupRoot,
			),
			"myGroup"=> $this->ioInfo(KodIO::KOD_GROUP_ROOT_SELF),
			'shareToMe'=> $this->ioInfo(KodIO::KOD_USER_SHARE_TO_ME),
		);
		
		$groupInfo 	= Session::get("kodUser.groupInfo");
		$groupInfo 	= array_to_keyvalue($groupInfo,'groupID');//自己所在的组
		if( !$groupInfo[$groupRoot] ){
			unset($list['rootGroup']);
		}else{
			$auth = $groupInfo[$groupRoot]['auth'];
			$list['rootGroup']['auth'] = array("authValue"=>$auth['auth'],'authInfo'=>$auth);
		}
		//不归属于任何部门； 获只属于根部门则不显示我所在的部门；
		if(count($groupInfo) == 0 || (count($groupInfo) == 1 && $groupInfo[$groupRoot])  ){
			unset($list['myGroup']);
		}

		foreach ($list as &$item) {
			$item['isParent'] = true;
			if($item['open']){ //首次打开：默认展开的路径，自动加载字内容
				$item['children'] = $this->path($item['path']);
			}
		}
		
		if(!$this->pathEnable('myFav')){unset($list['fav']);}
		if(!$this->pathEnable('my')){unset($list['my']);}
		if(!$this->pathEnable('rootGroup')){unset($list['rootGroup']);}
		if(!$this->pathEnable('myGroup')){unset($list['myGroup']);}
		return array_values($list);
	}
	
	private function pathEnable($type){
		$model  = Model('SystemOption');
		$option = $model->get();
		if( !isset($option['treeOpen']) ) return true;
		
		// 单独添加driver情况;更新后处理;  单独加入文件类型开关,则根据flag标记;自动处理;
		// my,myFav,myGroup,rootGroup,recentDoc,fileType,fileTag,driver
		$checkType = array(
			'treeOpenMy' 		=> 'my',
			'treeOpenMyGroup' 	=> 'myGroup',
			'treeOpenFileType' 	=> 'fileType',
			'treeOpenFileTag' 	=> 'fileTag',
			'treeOpenRecentDoc' => 'recentDoc',
			
			'treeOpenDriver' 	=> 'driver',
			'treeOpenFav'		=> 'myFav',
			'treeOpenRootGroup'	=> 'rootGroup',
		);
		foreach ($checkType as $keyType=>$key){
			if(isset($GLOBALS['TREE_OPTION_IGNORE']) && $GLOBALS['TREE_OPTION_IGNORE'] == '1') break;
			if( $option[$keyType] !='ok'){
				$model->set($keyType,'ok');
				$model->set('treeOpen',$option['treeOpen'].','.$key);
				$result = true;
				$option = $model->get();
			}
		}
		if($result) return true;
		
		$allow = explode(',',$option['treeOpen']);
		return in_array($type,$allow);
	}
	
	/**
	 * 文件类型列表
	 */
	private function blockFileType(){
		$docType = KodIO::fileTypeList();
		$list	 = array();
		foreach ($docType as $key => $value) {
			$list[$key] = array(
				"name"		=> $value['name'],
				"path"		=> KodIO::makeFileTypePath($key),
				'ext'		=> $value['ext'],
				'extType'	=> $key,
				'icon' 		=> 'userFileType-'.$key,
			);
		}
		return $list;
	}
	
	/**
	 * 工具
	 */
	private function blockTools(){
		$list = $this->ioInfo(array(
			KodIO::KOD_USER_RECENT,
			KodIO::KOD_USER_SHARE,
			KodIO::KOD_USER_SHARE_LINK,
			KodIO::KOD_USER_RECYCLE,
		));
		if(!$this->pathEnable('recentDoc')){
			unset($list[KodIO::KOD_USER_RECENT]);
		}
		return array_values($list);
	}

	private function ioInfo($pick){
		$list = array(
			KodIO::KOD_USER_FAV			=> LNG('explorer.toolbar.fav'),
			KodIO::KOD_GROUP_ROOT_SELF	=> LNG('explorer.toolbar.myGroup'),
			KodIO::KOD_USER_RECENT		=> LNG('explorer.toolbar.recentDoc'),
			KodIO::KOD_USER_SHARE		=> LNG('explorer.toolbar.shareTo'),
			KodIO::KOD_USER_SHARE_LINK	=> LNG('explorer.toolbar.shareLink'),
			KodIO::KOD_USER_SHARE_TO_ME	=> LNG('explorer.toolbar.shareToMe'),
			KodIO::KOD_USER_RECYCLE		=> LNG('explorer.toolbar.recycle'),
			KodIO::KOD_SEARCH			=> LNG('common.search'),
		);
		$result = array();
		foreach ($list as $key => $name){
			$result[$key] = array(
				"name"	=> $name, 
				"path"	=> $key.'/',
				"icon"	=> trim(trim($key,'{'),'}')
			);
		}
		if(is_string($pick)){
			return $result[$pick];
		}else if(is_array($pick)){
			$pickArr = array();
			foreach ($pick as $value) {
				$pickArr[$value] = $result[$value];
			}
			return $pickArr;
		}		
		return $result;	
	}
	
}
