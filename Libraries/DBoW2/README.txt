The loading of the ORB Vocabulary txt file takes more than 5 minutes on iOS, making it unusable. Initially, I tried integrating a binary version from GitHub, but it still took around 3 minutes to load.

To identify the bottleneck, I used chrono and found that the original code in DBoW2 initializes a "cv::Mat(1, F::L, CV_8U)" instance in a while loop. This causes performance issues due to memory allocation overhead.

To optimize this, I allocated the total memory usage outside the loop using a vector with continuous memory allocation in one go. Now, it takes less than 20 seconds to load.
