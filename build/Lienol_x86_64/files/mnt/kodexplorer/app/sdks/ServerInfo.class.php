<?php 

/**
 * 服务器信息
 * CPU、内存使用率——mac未实现
 */
class ServerInfo {

    function __construct() {
        $this->sysOs = strtoupper(substr(PHP_OS, 0,3)) === 'WIN' ? 'win' : 'linux';
    }

    public function cpuUsage(){
        $action = 'cpuUsage'.ucfirst($this->sysOs);
        return $this->$action();
    }

    public function memUsage(){
        $action = 'memUsage'.ucfirst($this->sysOs);
        return $this->$action();
    }

    /**
     * cpu使用率-linux
     * @return void
     */
    public function cpuUsageLinux(){
        $mode = "/(cpu)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)/";
        $string = shell_exec("more /proc/stat");
        preg_match_all($mode,$string,$arr);
        $total1 = $arr[2][0]+$arr[3][0]+$arr[4][0]+$arr[5][0]+$arr[6][0]+$arr[7][0]+$arr[8][0]+$arr[9][0];
        $time1 = $arr[2][0]+$arr[3][0]+$arr[4][0]+$arr[6][0]+$arr[7][0]+$arr[8][0]+$arr[9][0];
        sleep(1);
        $string = shell_exec("more /proc/stat");
        preg_match_all($mode,$string,$arr);
        $total2 = $arr[2][0]+$arr[3][0]+$arr[4][0]+$arr[5][0]+$arr[6][0]+$arr[7][0]+$arr[8][0]+$arr[9][0];
        $time2 = $arr[2][0]+$arr[3][0]+$arr[4][0]+$arr[6][0]+$arr[7][0]+$arr[8][0]+$arr[9][0];

        return !($total2-$total1) ? 0 : round(($time2-$time1)/($total2-$total1), 3);
        // return !($total2-$total1) ? '0%' : sprintf("%.1f",($time2-$time1)/($total2-$total1)*100).'%';
    }
    
    /**
     * 内存使用率-linux
     * @return void
     */
    public function memUsageLinux(){
        $str = shell_exec("more /proc/meminfo");
        $mode = "/(.+):\s*([0-9]+)/";
        preg_match_all($mode,$str,$arr);
        $data = array(
            'total' => (float) $arr[2][0],
            'used' => (float) $arr[2][0] - (float) $arr[2][2],
        );
        // $data['percent'] = !$data['total'] ? '0%' : sprintf("%.1f",$data['used']/$data['total']*100).'%';
        return $data;
    }

    /**
     * cpu使用率-win
     * @return void
     */
    public function cpuUsageWin(){
        $str = shell_exec('powershell "Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty LoadPercentage"');
        return round($str, 1)/100;
        // return trim($str) . '%';
    }
    
    /**
     * 内存使用率-win
     * @return void
     */
    public function memUsageWin(){
        $str = shell_exec('powershell "Get-CimInstance Win32_OperatingSystem | FL TotalVisibleMemorySize, FreePhysicalMemory"');
        $list = explode("\n", trim($str));
        $list = array_filter($list);
        
        $data = array();
        foreach($list as $value) {
            $tmp = explode(':', $value);
            $data[] = (float) trim($tmp[1]);
        }
        $data = array(
            'total' => $data[0],
            'used' => ($data[0] - $data[1]),
        );
        // $data['percent'] = !$data['total'] ? '0%' : sprintf("%.1f",$data['used']/$data['total']*100).'%';
        return $data;
    }
}