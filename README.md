# ApPredict_GP

A bolt-on extension to www.github.com/Chaste/ApPredict to use Gaussian Process emulators to allow us to do uncertainty quantification more quickly and easily.

## Schematic of the emulator of APD90

![schematic of APD90 emulator](https://github.com/sanmitraghosh/ApPredict_GP/blob/master/SimulatorEmulator.png)

## Dependencies

Before using this code you will need to download and install Chaste's
dependencies and the Chaste source code itself. We also need the source code of the ApPredict library.

To install these dependencies do the following:
### Get Chaste dependencies
The best way to do this is to install a dependency package for Ubuntu. Follow section 1 & 2 in https://chaste.cs.ox.ac.uk/trac/wiki/InstallGuides/UbuntuPackage to do this.

## Installation

Once the Chaste dependencies are installed get the Chaste source code. 

```bash
$ git clone -b develop https://chaste.cs.ox.ac.uk/git/chaste.git Chaste
```
I would suggest at this point to clone ApPredict, ApPredict_GP libraries as well:
```bash
$ git clone --recursive https://github.com/Chaste/ApPredict.git
$ git clone  https://github.com/sanmitraghosh/ApPredict_GP.git
```
and put a symbolic link inside `<chaste source directory>/projects`
```bash
cd <chaste source directory>/projects
ln -s <path/to/ApPredict>
ln -s <path/to/ApPredict_GP>
```

Now we have got everything setup to compile Chaste and the two projects. In Chaste we use cmake and we use a seperate directory for build.
```bash
$ mkdir chaste-build
$ cd chaste-build
$ ccmake <path/to/chaste source directory>
```
Type `c` to configure; when this process is complete, type `e` to exit the configuration. You should find that additional lines have been added to cmake with both the ApPredict and ApPredict_GP project names. Turn all option `ON` for these projects. 
Type `c` to configure once more, then `e` to exit and `g` to generate. When this process is complete, type 
```bash
$ make -jN
```
to build. Replace `N` with the number of cores you want to use for the build.

Once compilation is finished test that the APD simulator works with the following command:

```bash
$ cd projects/ApPredict_GP/apps
$ ./ApdCalculatorApp --gNa 0.9 --gKr 0.1 --gKs 0.5 --gCaL 0.8
```
It will throw some warnings but will return an APD value around 700. Ok so now you have got Chaste, ApPredict and ApPredict_GP installed and working.

To finish the installation we have to link C++ to MATLAB. To do this copy 

```bash
$ cp <path/to/chaste-build/projects/ApPredict_GP/apps/ApdCalculatorApp> <path/to/ApPredict_GP/MATLAB>
```
NB: copy the `ApdCalculatorApp` from only within `chaste-build/../apps` to the cloned ApPrdict_GP directory to ensure nothing is broken.

Once you do this go to the `<path/to/ApPredict_GP/MATLAB>` directory and modify the `matlab_wrapper.sh` file where commented to link up. This bit is pretty easy but needs to be done according to your own directory structure.

Now open MATLAB and change the working directory to `<path/to/ApPredict_GP/MATLAB>` and run the `testCommunication.m` script. This will generate a message to indicate MATLAB-C++ connection is okay.


## Running

To run the GP emulator and carry out some tests as in the paper follow the `readme` within the `MATLAB` directory. To test the LUT based interpolator see within `test` folder.
