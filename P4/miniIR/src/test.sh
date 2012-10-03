#!/bin/bash

javac Simplify.java
i=0
j=0
for file in tests/*.java
do
     i=$((i+1))
     
     echo "--------------$file------------------"
     T=`basename $file | sed s/.java//`
     
     #Your MiniIR generation
     java Simplify < $file > /tmp/mj.miniIR
     java -jar pgi.jar < /tmp/mj.miniIR > /tmp/mj.out
     
     #The actual output
     java -jar pgi.jar < /tests/$T.pg > /tmp/$T.out
     diff /tmp/mj.out /tmp/$T.out > /dev/null
     if [ $? -eq 0 ]; then
         echo $T passed;
         j=$((j+1))
     else
         echo $T failed;
     fi
     rm tests/*.class
done
echo "Done. ($j/$i) passed."
