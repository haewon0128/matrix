#!/bin/bash

function dims(){

if [[ $# -gt 1 ]]                                       # to throw error message when the number of argument is bigger than 1
then                                                    # redirect to stderr
echo "Invalid number of argumets" 1>&2                  # after that, return 1 that means not okay and exit matrix
exit 1
fi
 


mat="datafile$$"                             # *From program 1 assignment, according to the hint
if [ "$#" = "0" ]                           #according to the hint, it will allow to use one variable to hold the path to a file
then                                  #with passed-in content, no matter if they came via stdin or a file specified on the command line
cat > "$mat"                          # i don't know how to explain it so just used from program 1 hint
elif [ "$#" = "1" ]
then 
mat=$1
fi 


if ! [[ -r $mat ]]                     #throw error message when the file name is not correct same with incorrect number argument
then                                   # return 1 and exit matrix
echo "No such file found" 1>&2
exit 1
fi


x=0

while read num                       # read each line using while
do
	((x++))                      #increment x to count the number of rows

done < $mat

total=$(wc -w < $mat)                # get total numbers of integer in the matrix using word count
i=$(($total / $x))                   #divide the total to get column numbers
	
echo $x $i                           #print out row and colum 

}



function transpose(){

mat=$1

if [[ $# -gt 1 ]]                        #same with dimension function.. if the arguemnt number is not valid, redirect to stderr
then echo "Invalid of arguments" 1>&2    #return 1 and exit matrix
exit 1
fi


if ! [[ -r $mat ]]                      #same with dimension. check valid file name
then
echo "No such file found" 1>&2
exit 1                                  #not valid then redirect to stderr then return 1 and exit matrix
fi 

dr="drfile"                             #make file to use cut command

ddr=$(dims $1)                          # getting dimesion of m1 from dimension function

echo "$ddr" > $dr                       #put the value into dr file


row=$(cut -f 1 -d ' ' $dr)              # get row from dim

col=$(cut -f 2 -d ' ' $dr)              #get col from dim

start=1

tempCol="tempcolfile"                    #make file to use cat command
tempRow="temprowfile"                    #make file to use cat command


echo -n "" > $tempCol                      #just in case.. empty the file
echo -n "" > $tempRow                      #empty the file

for (( i=$start; i<=$col; i++ ))           
do

cut -f $i -d '	' $mat > $tempCol           #getting each column

myvar=$(cat $tempCol | tr '\n' '\t')         #change the newlines to tab in the columns, then columns becomes rows
myvar=${myvar%?}                            # remove the last character which is extra tab
echo "$myvar" >> "$tempRow"                 #append rows into temprow file


done



cat $tempRow                              #showing the result

rm $tempCol                                #remove temp files
rm $tempRow
}

function mean(){

if [[ $# -gt 1 ]]                          #same with dimension, transpose function..
then
echo "Invalid of argumnets" 1>&2
exit 1
fi

mat=$1

if ! [[ -r $mat ]]                       #same with dimension and transpose function
then
echo "no_such_file" 1>&2
exit 1
fi

dr="drfile"                              #make dr file to get dimension for dims

ddr=$(dims $1)

echo "$ddr" > $dr                       #put the dimesion of m1 into dr file


row=$(cut -f 1 -d ' ' $dr)                 #getting row

col=$(cut -f 2 -d ' ' $dr)                    #getting column

tempresult="tempresultfile"                   #make temp file to cat command at the end of the function

result="resultfile"                          #make result file to get result and cat command to show the result
start=1


echo -n "" > $tempresult               #just in case, empty the file

echo -n "" > $result                      #just in case, empty the file



for (( i=$start; i<=$col; i++ ))
do 
mynum=$(cut -f $i -d '	' $mat)             #get each colum into mynum

sum=0
for j in $mynum                    #add numbers in the column
do
sum=$(($sum + $j)) 


if [[ $sum -gt 0 ]]                     #if the sum is positive number ex) 1.7 
then
mean=$((($sum + ($row/2)*(1))/$row))        #round the number to close integer. 1.7 >2 and that is mean
fi

if [[ $sum -lt 0 ]]                       #if the sum is negative number ex)-2.3
then
mean=$((($sum + ($row/2)*(-1))/$row))         #round the number to close integer -2.3 > -2 and that is mean
fi

if [[ $sum -eq 0 ]]                #if the sum is equal to 0 then the mean is 0
then
mean=0
fi


done

echo $mean >> $tempresult      #redirect the means into tempresult file

done

myval=$(cat $tempresult | tr '\n' '\t')        #change new lines to tab in the tempresult file
myval=${myval%?}                                #remove the last character, extra tab
echo "$myval" >> $result                       #redirect the final result into result file
cat $result                                      # showing the result



rm $result                                      #remove files because if not, the numbers that i used still remained in the file
rm $tempresult


}


function add(){

if [[ $# -gt 2 || $# -lt 2 ]]                     #if the number of arguments is not equal to 2 then redirect to stderr
then                                               #return 1 and exit matrix
echo "Invalid of arguments" 1>&2
exit 1
fi

mat1=$1               #mat1 is first argument
mat2=$2                #mat2 is second argument

if ! [[ -r $mat1 ]] || ! [[ -r $mat2 ]]         #if the names of the arguments are not correct then redirect to stderr
then
echo "no such file found" 1>&2             
exit 1                                            #return 1 and exit matrix
fi


dr1="drfile1"

ddr1=$(dims $1)

echo "$ddr1" > $dr1                       #save dimension of m1 in to dr1 file


row1=$(cut -f 1 -d ' ' $dr1)            #getting row of m1

col1=$(cut -f 2 -d ' ' $dr1)            #getting col of m1


dr2="drfile2"

ddr2=$(dims $2)

echo "$ddr2" > $dr2                      #save dimension of m2 into dr2 file


row2=$(cut -f 1 -d ' ' $dr2)               #getting row of m2

col2=$(cut -f 2 -d ' ' $dr2)               #getting col of m2


if [[ $row1 -ne $row2 ]] || [[ $col1 -ne $col2 ]]          #by the law of matrix addition, the dimension of two matrix should be same
then                                                       # if they are not same, then redirect to stderr then retun 1 and exit matrix
echo "Use same dimension of matrices" 1>&2
exit 1
fi

newmat="newmatfile"
result="resultfile"
tempresult="tempresultfile"


echo -n "" > $newmat             #just in case, empty the files
echo -n "" > $result
echo -n "" > $tempresult

temprow1="temprowfile1"

echo -n "" > $temprow1             #empty the file
cat $mat1 | tr '\n' '\t' > "$temprow1"               #make m1 into one line by chaning the newline into tab and put in temprow1 file
echo >> "$temprow1"                                #add newline

temprow2="temprowfile2"

echo -n "" > $temprow2                     #empty the file
cat $mat2 | tr '\n' '\t' > "$temprow2"     #make m1 into one line by changing the newline into tab and put in temprow2 file
echo >> "$temprow2"                  #add newline


for (( i=1; i<=$(($row1*$col1)); i++ ))          #for as many as the number of integers in the matrix
do
sum=0
num1=$(cut -f $i $temprow1)                #getting integer in m1 in ith 
num2=$(cut -f $i $temprow2)                #getting integer in m2 in ith
sum=$(($num1 + $num2))                      #getting sum of the integers
echo $sum >> $tempresult                   # put the results in tempresult file
done


cat $tempresult | tr '\n' '\t' > "$result"        #make result into the oneline 
echo >> "$result"                                   #add newlines


for (( j=1; j<=$row1; j++ ))                    #make the oneline result into row1*col1 matrix
do

cut -f $(($col1 * $j - ($col1 - 1)))-$(($col1 * $j))  $result >> "$newmat"  #cut the oneline at the col1th as many as the number of row1
                                                                              #put into newmat file
              
done

cat $newmat               #show the new matrix

rm $temprow1            #remove all the file that i used
rm $temprow2
rm $newmat
rm $tempresult
rm $result
}

function multiply(){



if [[ $# -gt 2 || $# -lt 2 ]]                #same with add funtion
then
echo "Invalid of arguments" 1>&2
exit 1
fi

mat1=$1
mat2=$2

if ! [[ -r $mat1 ]] || ! [[ -r $mat2 ]]        #same with add function  
then
echo "no such file found" 1>&2
exit 1
fi


dr1="drfile1"

ddr1=$(dims $1)

echo "$ddr1" > $dr1


row1=$(cut -f 1 -d ' ' $dr1)

col1=$(cut -f 2 -d ' ' $dr1)


dr2="drfile2"

ddr2=$(dims $2)

echo "$ddr2" > $dr2


row2=$(cut -f 1 -d ' ' $dr2)

col2=$(cut -f 2 -d ' ' $dr2)                   #same with add function until here


if [[ $col1 -ne $row2 ]]                                #by the law of matrix multiply, the col1 and row2 should be same
then
echo "Not proper dimension for matrix multiply" 1>&2       #if not, redirect to stderr and return 1 and exit matrix
exit 1
fi




#make files i will use
newmat="newmatfile"
result="resultfile"
temprow="temprowfile"
tempcol="tempcolfile"
temptrans="temptransfile"
tempresult="tempresultfile"



while read currLine                       #read each line of mat1
do

echo "$currLine" > $temprow               #store the line into temprow file


for (( i=1; i<=$col2; i++ ))                          #get each column of matrix2
do      
cut -f $i -d '	' $mat2 > $tempcol
cat $tempcol | tr '\n' '\t' > "$temptrans"            #and change the column into row changing the newline into tab
                                                      #store into temptrans


sum=0
for (( j=1; j<=$row2; j++ ))                            
do
num1=$(cut -f $j $temprow)                 #getting jth number in the temprowfile (mat1)
num2=$(cut -f $j $temptrans)                #getting jth number in the temptransfile (mat2)


multi=$(($num1 * $num2))              #muliply the numbers
sum=$(($sum + $multi))               #store into sum

done
echo $sum >> $tempresult             #append the sums into tempresult file
done


done < $mat1


cat $tempresult | tr '\n' '\t' > "$result"              #because i appened the numbers, it's one column. so change it to one line
echo >> "$result"                                     #add new line

for (( k=1; k<=$row1; k++ ))                    #cut the oneline at the kth as many as the number of row1
do

cut -f $(($col2 * $k - ($col2 - 1)))-$(($col2 * $k)) $result  >> "$newmat"       #append the lines in newmat file


done

cat $newmat                      #show new matrix


#remove the files that i used
rm $newmat
rm $result
rm $tempresult
rm $temprow
rm $tempcol
rm $temptrans





}















$1 "${@:2}"
