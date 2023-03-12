CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

# Remove previous directories
rm -rf student-submission
rm -rf out
rm -f ListExamples.java

# Verify arguments
if [[ $# -eq 0 ]]
then
    echo 'Missing repository argument'
    exit 1
fi

# Clone student submission
git clone $1 student-submission
if [[ $? -eq 0 ]]
then
    echo 'Finished cloning'
else
    exit 1
fi

# Verify ListExamples.java submitted
if [[ -f student-submission/ListExamples.java ]]
then
    echo 'ListExamples.java found'
    cp student-submission/ListExamples.java ./
else
    echo 'Missing file ListExamples.java'
    exit 1
fi

# Verify filter method signature
grep -q 'static List<String> filter(List<String> list, StringChecker sc)' ListExamples.java
if [[ $? -eq 0 ]]
then
    echo 'filter method header found'
else
    echo 'filter method header missing'
    exit 1
fi

# Verify merge method signature
grep -q 'static List<String> merge(List<String> list1, List<String> list2)' ListExamples.java
if [[ $? -eq 0 ]]
then
    echo 'merge method header found'
    mkdir out out/logs
else
    echo 'merge method header missing'
    exit 1
fi

# Verify code compiles
javac -d out -cp $CPATH *.java > out/logs/compile.log 2>&1
if [[ $? -eq 0 ]]
then
    echo 'Compile successful'
else
    echo 'Could not compile ListExamples.java'
    exit 1
fi

# Run tests and save output to test.log
java -cp "${CPATH}:out" org.junit.runner.JUnitCore TestListExamples > out/logs/test.log 2>&1
if [[ $? -eq  0 ]]
then
    TESTS=1
    FAILS=0
else
    RESULTS=`grep 'Tests run:' out/logs/test.log`
    TESTS=${RESULTS:11:1}
    FAILS=${RESULTS:25:1}
fi

# Return score
SCORE=$((($TESTS - $FAILS) * 100 / $TESTS))
echo "Score: $SCORE / 100"
