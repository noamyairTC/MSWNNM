# [Multi-Scale Weighted Nuclear Norm Image Restoration](https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf)

The code available here is an implementation of the "Multi-Scale Weighted Nuclear Norm Image Restoration" [paper](https://tomer.net.technion.ac.il/files/2018/03/MultiScaleWNNM_CVPR18.pdf), Conference on Computer Vision and Pattern Recognition ([CVPR 2018](http://cvpr2018.thecvf.com)).

Please feel free to contact me at [noamyair10.tc@gmail.com](noamyair10.tc@gmail.com).<br />
Noam Yair.


# Running the Code
- **A Simple Example**<br />
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

# Some Visual Comparison Examples (from the paper)
Our algorithm handles arbitrary degradations within a single simple framework. It relies on a novel regularization term which encourages similar patches within and [across scales](https://youtu.be/YKULDPyrKZs) of the image to lie on low-dimensional subspaces. This leads to state-of-the-art results in tasks like inpainting and deblurring.<br />

- ** Example 1: Inpainting with 75\% missing pixels on Images from the [NCSR Set](http://www4.comp.polyu.edu.hk/~cslzhang/NCSR.htm)**<br />
Our algorithm produces a naturally looking reconstruction with sharp edges and no distracting artifacts. This is also supported by the high PSNR values it attains w.r.t. competing approaches.<br />

**Image Butterfly**<br />
<p align="center">
<img src="/Misc/ResultsExamples/1_InpaintButterfly.png" width="600">
</p>

**Image Starfish**<br />
<p align="center">
<img src="/Misc/ResultsExamples/5_InpaintingStarfish.png" width="1000">
</p>

- ** Example 2: Deblurring on Images from the [BSD100 Set](https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/)**<br />
On each example, a degraded input image from the BSD dataset is shown on the top left. It suffers from Gaussian blur with standard deviation 1.6 and additive noise with STD 2. As can be seen, while all state-of-the-art deblurring methods produce artifacts in the reconstruction, our algorithm produces sharp results without annoying distortions. Its precision is also confirmed by the very high PSNR it attaines w.r.t. the other methods.<br />

**Image 86000**<br />
<p align="center">
<img src="/Misc/ResultsExamples/2_Deblurring86000.png" width="700">
</p>

**Image 3096**<br />
<p align="center">
<img src="/Misc/ResultsExamples/3_Deblur3096.png" width="800">
</p>

**Image 210088**<br />
<p align="center">
<img src="/Misc/ResultsExamples/4_Deblurring210088.png" width="500">
</p>
