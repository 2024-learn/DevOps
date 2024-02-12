for i in $(seq 1 10000)
do
  curl http://a5bed8661577d42abb18ebc3eb6cf57d-828642261.ca-central-1.elb.amazonaws.com > test.txt
done