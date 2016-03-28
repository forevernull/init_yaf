#!/bin/bash
if [ -z $1 ]; then
    echo "usage: ./init_Yaf.sh  path [apache|nginx|lighttp]"
    echo 
    echo -e "eg:\033[32m\033[04m./init_Yaf.sh test apache\033[0m"
    exit 0
fi


if [[ -n "$1" && ! -d "$1" ]]; then
    mkdir $1
fi
cd $1

#To Create the documents
lsTree=("public" "public/css" "public/js" "public/img" "conf" "application" "application/controllers" "application/views" "application/views/index" "application/library" "application/models" "application/plugins")
for path in ${lsTree[*]}; do
    if [ ! -d "$path" ]; then
        mkdir $path
    fi
done


#htaccess
#depend on your server type([apache] nginx lighttp)

#Default apache htaccess
#if [[ -z "$2" || "$2"="apache" ]];then
htaccess="#.htaccess
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule .* index.php"
#fi

#Nginx
if [[ -n $2 && $2 = nginx ]];then
htaccess='server {
    listen ****;
    server_name  domain.com;
    root   document_root;
    index  index.php index.html index.htm;

    if (!-e $request_filename) {
        rewrite ^/(.*)  /index.php/$1 last;
        }
    }'
fi

#Lighttp htaccess
if [[ -n $2 && $2 = lighttp ]];then
htaccess='$HTTP["host"] =~ "(www.)?domain.com$" {
    url.rewrite = (
        "^/(.+)/?$"  => "/index.php/$1",
    )
}'
fi

#output to .htaccess
if [ ! -f ".htaccess" ]; then
    echo "$htaccess">>public/.htaccess
fi



#index.php
index='<?php
define("APPLICATION_PATH",  dirname(dirname(__FILE__)));

$app  = new Yaf_Application(APPLICATION_PATH . "/conf/application.ini");
$app->bootstrap() //call bootstrap methods defined in Bootstrap.php
    ->run();'

if [ ! -f "public/index.php" ]; then
    echo "$index">>public/index.php
fi
#application.ini
config='[product]
;CONSTANTS is supported
application.directory = APPLICATION_PATH "/application/"'

if [ ! -f "conf/application.ini" ]; then
    echo "$config">>conf/application.ini
fi

#Bootstrap.php
bootstrap='<?php
    class Bootstrap extends Yaf_Bootstrap_Abstract{ 
        function run(){        
            return true;       
        }
    }'
if [ ! -f "application/Bootstrap.php" ]; then
    echo "$bootstrap">>application/Bootstrap.php
fi


#Default controller
controller='<?php
    class IndexController extends Yaf_Controller_Abstract {
        //default action name
        public function indexAction() {  
            $this->getView()->content = "Hello World";
        }
    }'

if [ ! -f "application/controllers/Index.php" ]; then
    echo "$controller">>application/controllers/Index.php
fi

#view script
view='<html>
    <head>
        <title>Hello World</title>
    </head>
    <body>
        <h1><?php echo $content; ?></h1>
        <span style='color:#909090'>向鸟哥致敬<a href='http://weibo.com/laruence'>@laruence</a></span>
    </body>
</html>'

if [ ! -f "application/views/index/index.phtml" ]; then
    echo "$view">>application/views/index/index.phtml
fi

echo "Complete!"
echo "Please visit http://localhost/$1/pulic."
echo
echo "Niaoge suggested to visit: http://php.net/manual/zh/book.yaf.php"
echo "More infomation:https://github.com/laruence/php-yaf"
echo "Menual[Chinese]:http://www.laruence.com/manual/"
