UPPER=$(ls | grep -o '[0-9]\{1,\}' | sort -gr | head -n 1)

echo "Running $UPPER tests.."

for i in $(seq $UPPER)
do
  echo "Test $i: "
  time ./$1 < input.$i | sed "s/\s+$//g" | git diff --no-index output.$i -
  echo ""
done
