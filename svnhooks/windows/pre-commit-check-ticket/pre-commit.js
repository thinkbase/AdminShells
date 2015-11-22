var debug = function(msg){
	var d = new Date();
	var ts = d.getFullYear() + "-" + ("0" + d.getMonth()+1).slice(-2) + "-" + ("0"+(d.getDate())).slice(-2)
           + " " + ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2) + ":" + ("0" + d.getSeconds()).slice(-2);
	WScript.StdOut.WriteLine("["+ts+"] " + msg);
}

var WshShell = new ActiveXObject("WScript.Shell");
var args = WScript.Arguments;
var commitInfo = {
    repository : args(0),    //Repository path
    transaction: args(1)     //Commit transaction name
}
debug("repository: "+commitInfo.repository);
debug("transaction: "+commitInfo.transaction);

var DEFAULT_LOG_PATTERN  = /.*\#\d+\s.*/g;
var DEFAULT_PATH_PATTERN = /.*/g;
var DEFAULT_LOG_MIN_LEN  = 4;
/**
 * Read configuration file: pre-commit.json, Following is an example config file
  {
    //The commit log pattern
    LOG_PATTERN: new RegExp(".*\\#\\d+\\s.*", "g"),
    //Pattern for Paths which need check the commit log pattern;
	// NOTE: 1)"\" in path string should be replaced to "/" before match; 2)Path is WITHOUT head "/" and WITH tail "/", such as [/], [Project/product/]
    PATH_PATTERN: new RegExp(".*\/src\/.*", "g"),
    //The minimum length(letters) of commit log
    LOG_MIN_LEN: 3
  }
*/
var $conf = function(){
	var fso = new ActiveXObject("Scripting.FileSystemObject");
	var fConf = commitInfo.repository+"\\hooks\\pre-commit.json";
	var c = {};
	if (fso.FileExists(fConf)){
		debug("config file = " + fConf);
		var ForReading= 1;
		var f = fso.OpenTextFile(fConf, ForReading, false);
		var txt = f.ReadAll() + "";
		f.Close();
		debug("config file text = " + txt);
		var conf = eval("("+txt+")");
		c = conf;
	}else{
		debug("config file: <default>");
	}
	if (!c.LOG_PATTERN){
		c.LOG_PATTERN = DEFAULT_LOG_PATTERN;
	}
	if (!c.PATH_PATTERN){
		c.PATH_PATTERN = DEFAULT_PATH_PATTERN;
	}
	if (!c.LOG_MIN_LEN){
		c.LOG_MIN_LEN = DEFAULT_LOG_MIN_LEN;
	}
	
	debug("config: LOG_PATTERN = " + c.LOG_PATTERN);
	debug("config: PATH_PATTERN = " + c.PATH_PATTERN);
	debug("config: LOG_MIN_LEN = " + c.LOG_MIN_LEN);
	
	return c;
}
//Clone a RegExp Object
var $regexp = function(regexp){
	var flags = [];
    if (regexp.global) flags.push('g');
    if (regexp.multiline) flags.push('m');
    if (regexp.ignoreCase) flags.push('i');
    return new RegExp(regexp.source, flags.join(''));
}
// Replace command line template with commit information
var $cmd = function(cmd) {
	var tmp = cmd.replace(/\$repo/g, '"' + commitInfo.repository + '"');
	tmp = tmp.replace(/\$trans/g, '"' + commitInfo.transaction + '"');
	debug("command: " + tmp);
    return tmp;
}
// Get the commit log
var $log = function() {
    var cmd = $cmd('svnlook log $repo -t $trans');
    var log = WshShell.Exec(cmd).StdOut.ReadAll();
	if (!log) log = "";
    log = log.replace(/^\s+|\s+$/g, '');	// Trim
    return log;
}
// Get the commit relation folders
var $dirs = function(){
	var paths = [];
	
    var cmd = $cmd('svnlook dirs-changed $repo -t $trans');
    var oExec = WshShell.Exec(cmd);
    var stdout = oExec.StdOut;
    while (!stdout.AtEndOfStream) {
        var line = stdout.ReadLine();
        line = line.replace(/\\/g, "/");    //"\" ==> "/"
        paths[paths.length] = line;
    }
    
    return paths;
}

var doCheck = function(){
	var conf = $conf();
	var errorBuf = [];

	var log = $log();
	debug("commit log: " + log);
	if (log.length < conf.LOG_MIN_LEN) {
		errorBuf[errorBuf.length] = "The commit log must be long then ["+conf.LOG_MIN_LEN+"] letters";
		return errorBuf;
	}
	
	var dirs = $dirs();
	debug("commit dirs: " + dirs);
	
	var checkPaths = [];
	for(var i=0; i<dirs.length; i++){
		var path = dirs[i];
		debug(" > check path: " + path);
		var pPath = $regexp(conf.PATH_PATTERN);
		var pathMatch = pPath.test(path);
		debug("  >> need check log = ["+pathMatch+"], for path: " + path);
		if (pathMatch){
			checkPaths[checkPaths.length] = path;
		}
	}
	if (checkPaths.length > 0){
		var pLog = $regexp(conf.LOG_PATTERN);
		var logMatch = pLog.test(log);
		debug(" > log match the pattern = ["+logMatch+"]");
		if (! logMatch){
			errorBuf[errorBuf.length] = "Paths '"+checkPaths+"': The commit log must match the pattern ["+pLog+"]";
			return errorBuf;
		}		
	}
	
	return errorBuf;
}

var errors = doCheck();

//Return
if(errors.length <= 0){
    WScript.Quit(0);
}else{
    WScript.StdErr.WriteLine(">>> pre-commit.js:");
    for (var i=0; i<errors.length; i++){
        WScript.StdErr.WriteLine( (i+1) + ". "+errors[i] );
    }
    WScript.StdErr.WriteLine(".");
    WScript.Quit(1);
}
