#!/bin/bash

javac MiniIR.java
i=0
j=0
for file in tests/test*.java
do
     i=$((i+1))
     
     echo "--------------$file------------------"
     T=`basename $file | sed s/.java//`
     
     #Your MiniIR generation
     java MiniIR < $file > /tmp/mj.miniIR
     java -jar pgi.jar < /tmp/mj.miniIR > /tmp/mj.out
     
     #The actual output
     cd
     #javac $file
     #java ./$dir/$T > /tmp/$T.out
     # cd ..
     #diff /tmp/mj.out /tmp/$T.out > /dev/null
     #if [ $? -eq 0 ]; then
     #    echo $T passed;
     #    j=$((j+1))
     #else
     #    echo $T failed;
     #fi
     #rm tests/*.class
done
echo "Done. ($j/$i) passed."
