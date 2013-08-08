RUN=$1
TEST=$2

function input_file()
{
  echo "tablica.in.$1"
}

function output_file()
{
  echo "tablica.out.$1"
}

function run_test()
{
  echo "Test #$1:"
  time ./$RUN < $(input_file $1) | diff -wa $(output_file $1) -
  echo ""
}

function fix_run()
{
  if [ -z $RUN ]; then
    RUN=$(ls | grep *.cpp | head -n 1 | sed "s/.cpp//g")
  fi
}

fix_run

if [ -z $RUN ]; then
  echo "No program to test."
fi

if [ -z $TEST ]; then
  UPPER=$(ls | grep -o '[0-9]\{1,\}' | sort -gr | head -n 1)

  for i in $(seq $UPPER)
  do
    run_test $i
  done
else
  run_test $2
fi

