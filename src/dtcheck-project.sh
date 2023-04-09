#!/bin/sh
echo "此脚本的作用：在本地git项目里，更新指定分支的git远程仓库代码，通过maven的dependency-track插件命令检查项目依赖的三方库(项目必须是基于maven构建的)，并将结果上传到Dependency-Track服务器。"
echo "执行此脚本的前提：1.本地安装git并配置全局环境变量；2.本地安装maven并配置全局环境变量；3.项目是基于maven构建的；"
echo "此脚本接收三个参数："
echo "第一个参数，本地git项目的根目录全路径(必需)，指定待检查的本地git项目的根目录全路径；"
echo "第二个参数，是否拉取远程git仓库的最新代码(必需)，y-是，其他-否；"
echo "第三个参数，git的分支名(可选)，指定待检查的git的本地分支（会切换到该分支下），默认为当前分支。"
echo "指定的第三个参数，如果本地分支不存在，则会使用当前分支；如果同名远程分支不存在，则不执行代码更新。"
echo ""
DEPENDENCYURL=$(head -1 config)
DEPENDENCYURL_ERROR=$(echo $?) #检查上一步命令执行的结果：值为0表示成功，其他值表示失败
if [ "$DEPENDENCYURL_ERROR" != "0" ] || [ "$DEPENDENCYURL" = "" ];then
	echo "[error]获取Dependency-Track服务器地址失败，请确认脚本的同级目录下存在config文件且文件中的第一行为Dependency-Track服务器地址!"
	exit 1
fi
DEPENDENCYLOGIN=$(sed -n '2p' config)
DEPENDENCYLOGIN_ERROR=$(echo $?) #检查上一步命令执行的结果：值为0表示成功，其他值表示失败
if [ "$DEPENDENCYLOGIN_ERROR" != "0" ] || [ "$DEPENDENCYLOGIN" = "" ];then
	echo "[error]获取Dependency-Track服务器的用户令牌失败，请确认脚本的同级目录下存在config文件且文件中的第二行为Dependency-Track服务器的用户令牌!"
	exit 1
fi

if [ "$1" = "" ];then
	echo "[error]缺少第一个参数，参数为：待检查的本地git项目的根目录全路径"
	exit 1
fi

if [ "$2" = "" ];then
	echo "[error]缺少第二个参数，参数为：是否拉取远程git仓库最新代码，y-是，其他-否"
	exit 1
fi

cd $1
NO_DIRECTORY=$(echo $?)
if [ "$NO_DIRECTORY" != "0" ];then
	echo "[error]本地目录输入错误或不存在，需使用linux系统的目录格式!"
	exit 1
fi
echo "进入到待扫描的本地git项目的根目录下..."
DIRECTORY=$(pwd)
echo "$DIRECTORY"
PROJECT=$(mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.artifactId -q -DforceStdout)
MAVEN_ERROR=$(echo $?)
echo "maven的artifactId为：$PROJECT"
if [ "$MAVEN_ERROR" != "0" ] || [ "$PROJECT" = "" ];then
	echo "[error]执行maven命令失败。请确保此目录$DIRECTORY的项目为maven项目，并且在项目的根目录下；请确认本地安装了maven，并设置了全局的环境变量！"
	exit 1
fi
if [ "$3" != "" ];then
	echo "切换到指定的git分支下，分支：$3"
	git checkout $3
fi
BRANCH=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
echo "git的当前分支为：$BRANCH"
if [ "$BRANCH" = "" ];then
	echo "[error]执行git命令失败。请确保此目录$DIRECTORY的项目为git项目，并且在项目的根目录下；请确认本地安装了git，并设置了全局的环境变量！"
	exit 1
fi

if [ "$2" = "y" ] || [ "$2" = "Y" ];then
	echo "开始拉取远程origin的$BRANCH分支代码..."
	git pull origin $BRANCH
fi


echo "开始执行dependency-track分析的maven命令..."
mvn org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom
mvn -N io.github.pmckeown:dependency-track-maven-plugin:upload-bom \
	-Ddependency-track.dependencyTrackBaseUrl=$DEPENDENCYURL \
	-Ddependency-track.apiKey=$DEPENDENCYLOGIN \
	-Ddependency-track.projectVersion=latest \
	-Ddependency-track.projectName=$PROJECT
MAVEN_DEPENDENCY_ERROR=$(echo $?)
if [ "$MAVEN_DEPENDENCY_ERROR" != "0" ];then
	echo "[error]执行dependency-track分析的maven命令失败，请检查config文件的配置信息是否正确，文件中第一行为Dependency-Track服务器地址，第二行为Dependency-Track服务器的用户令牌!"
	exit 1
fi
echo "执行dependency-track分析完成，上传到Dependency-Track服务器地址为：$DEPENDENCYURL"
echo "执行dependency-track分析完成，生成的Dependency-Track项目名称为：$PROJECT"
echo "执行结束！"