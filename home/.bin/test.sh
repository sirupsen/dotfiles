UPPER=$(ls | grep -o '[0-9]\{1,\}$' | sort -gr | head -n 1)

for i in $(seq $UPPER)
do
  echo "Diff for $i.."
  time ./$1 < input.$i > output.$i.program
  diff output.$i output.$i.program
  echo "\n"
done

rm *.program
