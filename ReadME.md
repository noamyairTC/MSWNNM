# [Multi-Scale Weighted Nuclear Norm Image Restoration](https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf)

The code available here is an implementation of the "Multi-Scale Weighted Nuclear Norm Image Restoration" [paper](https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf), Conference on Computer Vision and Pattern Recognition ([CVPR 2018](http://cvpr2018.thecvf.com)).

Please feel free to contact me at [noamyair10.tc@gmail.com](noamyair10.tc@gmail.com).<br />
Noam Yair.


# Running the Code
- **A Simple Example**
For a simple example of a deblurring case just run the 'RunMe.m' file.

- **Reproducing Paper Experiments**<br />
For reproducing the experiments from the paper use the 'ReproduceExperiments.m' file and follow the instruction in the documentation. You may also just run this funtion as-is for a simple example.

- **Additional Option**<br />
You may also run 'RunAlgorithm' function / file. Though, this function expect some inputs (the corrupted image, the noise level, etc.). Follow the documentation of this function to use it directly. Note: the purpose of the 'RunMe.m' function is to create the appropriate inputs for the 'RunAlgorithm' function and then call it. Therefore, you may found using the 'RunMe.m' function more convenient.

# Requirements and Dependencies
- Matlab with an Image Processing Toolbox.
- If using the IRCNN method for initialization, please see [IRCNN method page](https://github.com/cszn/IRCNN) (will require [MatConvNet](http://www.vlfeat.org/matconvnet/)).

# Citation
```
 @inproceedings{MSWNNM,
   title={Multi-Scale Weighted Nuclear Norm Image Restoration},
   author={Yair, Noam and Michaeli, Tomer},
   booktitle={IEEE Conference on Computer Vision and Pattern Recognition},
   year={2018},
 }
 ```