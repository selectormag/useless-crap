i=0 
# Just for fun
# Or maybe to exponentially stress your CPU

ENCODE="A"

while [[ $i -lt 51 ]]; do 
	ENCODE=$(echo $ENCODE | base64)
	echo "DONE WITH PASS $i" 
	i=$((i + 1))
done
echo $ENCODE > b64.test

i=0 
DECODE=$(cat b64.test)

while [[ $i -lt 51 ]]; do 
	DECODE=$(echo $DECODE | base64 --decode)
	echo "DONE WITH PASS $i"
	i=$((i + 1))
done
echo $DECODE >> b64.test
