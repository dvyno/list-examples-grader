CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
git clone $1 student-submission
echo 'Finished cloning'

# Check ListExamples.java exists
if [[ -f student-submission/ListExamples.java ]]
then
    echo "ListExamples found"
else
    echo "Need file ListExamples.java"
    exit 1
fi

# Copy tester to and library to student-submission
cd student-submission
cp ../TestListExamples.java ./
cp -R ../lib ./

# Compile tester
javac -cp $CPATH *.java 2> log.txt
if [[ $? -eq 0 ]]
then
    echo "Compile successful"
else
    echo "Could not compile ListExamples.java"
    # echo `cat log.txt`
    exit 1
fi

java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > log.txt
if [[ $? -eq 0 ]]
then
    # echo "Tests: PASSED"
    echo "Score: 100 / 100"
else
    # echo "Tests: FAILED"
    RESULT=`grep "Tests run:" log.txt`

    # Parse results for number
    # TESTS=${RESULTS:11:1}
    # FAILS=${RESULTS:25:1}
    TESTS=$(echo $RESULT | cut -f1 -d,)
    FAILS=$(echo $RESULT | cut -f2 -d,)
    TESTS=${TESTS#"Tests run: "}
    FAILS=${FAILS#" Failures: "}
    SCORE=$((($TESTS - $FAILS) * 100 / $TESTS))
    echo "Score: $SCORE / 100"
fi

