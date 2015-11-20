var args = WScript.Arguments;
var repository   = args(0);
var revision     = args(1);
var userName     = args(2);
var propertyName = args(3);
var action       = args(4);

//Pass modification or forbidden
var pass = (action == "M" && propertyName == "svn:log");

//Date and time
var d = new Date();
var strD = d.getFullYear() + "-" + ("0" + d.getMonth()+1).slice(-2) + "-" + ("0"+(d.getDate())).slice(-2);
var strTs = strD + " " + ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2) + ":" + ("0" + d.getSeconds()).slice(-2);

//Prepare log folder
var logDir = repository+"\\logs-pre-revprop-change";
var fso = new ActiveXObject("Scripting.FileSystemObject");
if (! fso.FolderExists(logDir)){
	fso.CreateFolder(logDir);
}

//Read old log
var tmpFile = args(5);
if (! fso.FileExists(tmpFile)){
	WScript.Quit(-1);
}
var ForReading= 1;
var fTmp = fso.OpenTextFile(tmpFile, ForReading, false);
var oldLog = fTmp.ReadAll() + "";
fTmp.Close();
fso.DeleteFile(tmpFile, true);
if (!oldLog) oldLog="";
oldLog = oldLog.replace(/^[\s]+/,'').replace(/[\s]+$/,''); //Trim

//Write log
var ForAppending= 8;
var ts = fso.OpenTextFile(logDir+"\\["+revision+"].log", ForAppending, true);
ts.WriteLine("==== Start revprop-change ====");
ts.WriteLine(strTs);
ts.WriteLine("pass = " + pass);
ts.WriteLine("-------- Original log --------");
ts.WriteLine(oldLog);
ts.WriteLine("------ Changing context ------");
ts.WriteLine("repository: " + repository);
ts.WriteLine("revision  : " + revision);
ts.WriteLine("user      : " + userName);
ts.WriteLine("property  : " + propertyName);
ts.WriteLine("action    : " + action);
ts.WriteLine("----------- Finish -----------");
ts.WriteLine("");
ts.WriteLine("");
ts.Close();

//Return
if(pass){
    WScript.Quit(0);
}else{
    WScript.Quit(1);
}
