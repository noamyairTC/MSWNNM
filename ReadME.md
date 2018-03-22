# [Multi-Scale Weighted Nuclear Norm Image Restoration](https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf)


The code available here is an implementation of the "Multi-Scale Weighted Nuclear Norm Image Restoration" [paper](https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf), Conference on Computer Vision and Pattern Recognition ([CVPR 2018](http://cvpr2018.thecvf.com)).

For questions, feel free to contact me at [noamyair10.tc@gmail.com](noamyair10.tc@gmail.com).<br />
Noam Yair.


# Running the Code and Reproducing Results
- **Simple Example**
  * For a simple example of a deblurring case just run the 'RunMe.m' file.

- **Reproducing Table 3 Experiments**<br />
For reproducing the results in Table 3 run the 'RunMe.m' file on the images from the BSD100 data-set.
  * BSD100 should be available in the [Berkeley website](https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/).
  * Make sure to run it on the gray-scale version images.
  * Set the input image using the 'imageFileName' parameter in the 'RunMe.m' file.

- **Reproducing Other Deblurring Experiments**<br />
For reproducing all other deblurring experiments (all deblurring experiments, except those on Table 3).
  * Change 'initType' parameter in 'SetAlgorithmParameters' file to '1' (this will execute a naive x=y initialization).
  * Change 'numItersMain' parameter in 'SetAlgorithmParameters' file (line 31) to 300.
  * Run the algorithm on the appropriate images (use the 'imageFileName' parameter in the 'RunMe.m' file to choose the input image.)
  * Note: using the naive initialization and running 300 iterations may take a few hours.

- **Reproducing Inpainting Experiments**<br />
For reproducing the inpainting results:
  * Change the 'initType' parameter in the 'SetAlgorithmParameters' file to '1' (this will execute a naive x=y initialization).
  * Change 'algorithmPurpose' parameter (in this file) to 'inpainting' (string).
  * Run the algorithm on the appropriate images (use the 'imageFileName' parameter in the 'RunMe.m' file.)
  * Note: usign the naive initialization may take a few hours.


# Requirements and Dependencies
- Matlab with an Image Processing Toolbox.
- If using the IRCNN method for initialization, please see [IRCNN method](https://github.com/cszn/IRCNN) page (will require [MatConvNet](http://www.vlfeat.org/matconvnet/)).


# Citation

```
 @inproceedings{MSWNNM,
   title={Multi-ScaleWeighted Nuclear Norm Image Restoration},
   author={Yair, Noam and Michaeli, Tomer},
   booktitle={IEEE Conference on Computer Vision and Pattern Recognition},
   year={2018},
 }
 ```