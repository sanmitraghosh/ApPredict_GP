# Example CMake build configuration file for a Chaste user project.
# See also https://chaste.cs.ox.ac.uk/trac/wiki/ChasteGuides/CmakeBuildGuide for full documentation.

# You can set which Chaste components (or other projects) your project depends on by editing the
# find_package() call for Chaste.  E.g.
find_package(Chaste COMPONENTS heart project_ApPredict)

# Change the project name in the line below to match the folder this file is in,
# i.e. the name of your project.
set(Chaste_PYCML_EXTRA_ARGS "--expose-annotated-variables")
chaste_do_project(ApPredict_GP)


