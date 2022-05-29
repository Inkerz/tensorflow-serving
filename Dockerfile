FROM public.ecr.aws/ubuntu/ubuntu:20.04 as builder

RUN apt-get update && apt-get install -y apt-transport-https curl gnupg git tar python3 python3-dev python3-numpy g++ gcc rsync

RUN curl -L https://github.com/bazelbuild/bazel/releases/download/3.0.0/bazel-3.0.0-linux-x86_64 --output /usr/bin/bazel
RUN chmod a+x /usr/bin/bazel

WORKDIR /build
RUN curl -L https://github.com/tensorflow/serving/archive/refs/tags/2.3.0.tar.gz | tar xz

WORKDIR /build/serving-2.3.0
RUN bazel build --jobs 20 //tensorflow_serving/apis:prediction_service_cc_proto //tensorflow_serving/apis:predict_cc_proto

RUN mkdir /tensorflow-serving-apis-2.3.0
RUN rsync -rav \
	--exclude=*.o \
	--exclude=*.d \
	--exclude=*.params \
	--exclude=*.cc \
	./bazel-out/k8-opt/bin/tensorflow_serving \
	/tensorflow-serving-apis-cc-2.3.0

WORKDIR /
RUN tar -czvf tensorflow-serving-apis-cc-2.3.0.tar.gz -C /tensorflow-serving-apis-cc-2.3.0 .

WORKDIR /artifacts
ENTRYPOINT cp /tensorflow-serving-apis-cc-2.3.0.tar.gz /artifacts


