## LightCalibration ##

In this project we will try to build a parametric light model for a point LED light: given a 3d position in the space, the light model will return its radiance based on the distance and angle to the point light.

### settings ###

A PrimeSense + a DSLR camera + a point LED light. The PrimeSense is used to get the depth image, the DSLR is used to get RAW color image. Fix them rigidly by using a mount, industrial glue, wood, or whatever you like. The LED light has to be placed in the xoy plane in PrimeSense coordinate(i.e., z = 0). It might be helpful to read [RGBDCameraCalibration](https://github.com/dut09/RGBDCameraCalibration) first, or I assume you have already know the transformation between the two cameras.

### step 1: calibrate the light position ###

Find a flat white wall, fix your equipment from 0.5m away from that wall, take depth and color images from the PrimeSense, and a color image from the DSLR. Repeat this for different distances from the wall. You can refer to \Position for some sample images.

Here I will use the stereo calibration results from the project [RGBDCameraCalibration](https://github.com/dut09/RGBDCameraCalibration), so I put the .mat file generated by stereo calibration under the root directory. As a first step, run init from the root. This will update the path information and load the stereo calibration results. Then run calib_light_position, this will help you compute the center of the highlight area in each image. We will fit a line based on these centers, and trace back to z = 0, assuming it is the position of the LED light.

### step 2: calibrate the radiance ###

TODO