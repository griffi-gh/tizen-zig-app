#!/usr/bin/env bash
cd $TIZEN/tools/ide
java -Dlog4j.configuration=log4j-progress.xml \
     -Djava.library.path=$TIZEN/tools/ide/lib-ncli/spawner \
     -cp $TIZEN/tools/ide/conf-ncli:$(find $TIZEN/tools/ide/lib-ncli -maxdepth 1 | tr '\n' ':')$TIZEN/library/sdk-utils-core.jar \
     org.tizen.ncli.ide.shell.Main "$@" --current-workspace-path "$PWD"