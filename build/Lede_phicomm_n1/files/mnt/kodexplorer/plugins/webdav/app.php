<?php

/**
 * webdav服务端;
 * 独立模块,不需要登陆,权限内部自行处理;
 */
class webdavPlugin extends PluginBase{
	function __construct(){
		$this->echoLog = 0;//开启关闭日志;
		parent::__construct();
	}
	public function regist(){
		$this->hookRegist(array(
			'user.commonJs.insert'  => 'webdavPlugin.echoJs',
			'globalRequest'			=> 'webdavPlugin.route',
		));
	}
	public function echoJs(){
		$config = $this->getConfig();
		$allow  = $this->isOpen() && $this->authCheck();
		$assign = array(
			"{{isAllow}}" 	 => intval($allow),
			"{{pathAllow}}"	 => $config['pathAllow'],
			"{{webdavName}}" => $this->webdavName(),
		);
		$this->echoFile('static/main.js',$assign);
	}
	private function webdavName(){
		$config = $this->getConfig();
		return $config['webdavName'] ? $config['webdavName']:'kodbox';
	}
	
	public function route(){
		$this->_checkConfig();
		if(strtolower(MOD.'.'.ST) != 'plugin.webdav') return;
		$action = ACT;//dav/download;
		if( method_exists($this,$action) ){
			$this->$action();exit;
		}
		$this->run();exit;
	}
	public function run(){
		if(!$this->isOpen()) return show_json("not open webdav",false);
		require($this->pluginPath.'php/kodWebDav.class.php');
		register_shutdown_function(array(&$this, 'endLog'));
		$dav = new kodWebDav('/index.php/plugin/webdav/'.$this->webdavName().'/'); // 适配window多一层;
		$this->debug($dav);
		$dav->run();
	}
	public function download(){
		IO::fileOut($this->pluginPath.'static/webdav.cmd',true);
	}
	public function _checkConfig(){
		$nowSize=_get($_SERVER,'_afileSize','');$enSize=_get($_SERVER,'_afileSizeIn','');
		if(function_exists('_kodDe') && (!$nowSize || !$enSize || $nowSize != $enSize)){exit;}
	}
	public function check(){
		echo $_SERVER['HTTP_AUTHORIZATION'];
	}
	public function checkSupport(){
		CacheLock::unlockRuntime();
		$url = APP_HOST.'index.php/plugin/webdav/check';
		$auth   = "Basic ".base64_encode('usr:pass');
		$header = array("Authorization: ".$auth);
		$res 	= @url_request($url,"GET",false,$header,false,false,3);
		if($res && substr($res['data'],0,11) == 'API call to') return true; //请求自己失败;
		if($res && $res['data'] == $auth) return true;
		
		@$this->setConfig(array('isOpen'=>'0'));
		return false;
	}

	public function onSetConfig($config){
		if($config['isOpen'] != '1') return;
		$this->onGetConfig($config);
	}
	public function onGetConfig($config){
		$this->autoApplyApache();
		if($this->checkSupport()) return;
		show_tips(
		"您当前服务器不支持PATH_INFO模式<br/>形如 /index.php/index方式的访问;
		同时不能丢失header参数Authorization;否则无法登录;
		<a href='http://doc.kodcloud.com/v2/#/help/pathInfo' target='_blank'>了解如何开启</a>",false);exit;
	}
	
	// apache 丢失Authorization情况自动加入配置;
	private function autoApplyApache(){
		$file = BASIC_PATH . '.htaccess';
		$isApache = strtolower($_SERVER['SERVER_SOFTWARE']) == 'apache';
		if(!$isApache || file_exists($file)) return;
		$arr = array(
			'RewriteEngine On',
			'RewriteCond %{HTTP:Authorization} ^(.*)',
			'RewriteRule .* - [e=HTTP_AUTHORIZATION:%1]',
		);
		file_put_contents($file,implode("\n",$arr));
	}

	private function isOpen(){
		$option = $this->getConfig();
		return $option['isOpen'] == '1';
	}
	private function debug($dav){
		$path = $dav->pathGet().';'.$dav->pathGet(true).';'.$dav->path;
		$this->log(' start;'.$path);
		if(strstr($_SERVER['HTTP_USER_AGENT'],'Chrome')){
			//PROPFIND;GET;MOVE;COPY,HEAD,PUT
			$_SERVER['REQUEST_METHOD'] = 'PROPFIND';
		}
	}
	public function endLog(){
		$this->log(' end  ;['.http_response_code().'];'.$_SERVER['REQUEST_URI']);
	}
	public function log($data){
		if(!$this->echoLog) return;
		if($_SERVER['REQUEST_METHOD'] == 'PROPFIND' ) return;
		if(is_array($data)){$data = json_encode_force($data);}
		
		$data = $_SERVER['REQUEST_METHOD'].' '.$data;
		// $data = array($data,$GLOBALS['__SERVER']);
		write_log($data,'webdav');
	}
}