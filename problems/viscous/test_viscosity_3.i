[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

######################################################################################################
# Mesh 
######################################################################################################

[Mesh]
  [whole_mesh]
    type = GeneratedMeshGenerator
    dim = 3
    elem_type = HEX8
    nx = 5
    ny = 20
    nz = 30
    xmin = 0
    xmax = 5
    ymin = 0
    ymax = 20
    zmin = 0
    zmax = 30
  []
  [rename_block1]
    type = SubdomainBoundingBoxGenerator
    input = whole_mesh
    bottom_left = '0 0 0'
    top_right = '5 5 15'
    block_id = 1
  []
  [rename_block2]
    type = SubdomainBoundingBoxGenerator
    input = rename_block1
    bottom_left = '0 0 15'
    top_right = '5 5 30'
    block_id = 2
  []
    [rename_block3]
    type = SubdomainBoundingBoxGenerator
    input = rename_block2
    bottom_left = '0 5 0'
    top_right = '5 10 10'
    block_id = 3
  []
  [rename_block4]
    type = SubdomainBoundingBoxGenerator
    input = rename_block3
    bottom_left = '0 5 25'
    top_right = '5 15 30'
    block_id = 4
  []
  [rename_block5]
    type = SubdomainBoundingBoxGenerator
    input = rename_block4
    bottom_left = '0 10 0'
    top_right = '5 15 15'
    block_id = 5
  []
  [rename_block6]
    type = SubdomainBoundingBoxGenerator
    input = rename_block5
    bottom_left = '0 15 0'
    top_right = '5 20 10'
    block_id = 6
  []
  [rename_block7]
    type = SubdomainBoundingBoxGenerator
    input = rename_block6
    bottom_left = '0 15 10'
    top_right = '5 20 20'
    block_id = 7
  []
  [rename_block8]
    type = SubdomainBoundingBoxGenerator
    input = rename_block7
    bottom_left = '0 15 20'
    top_right = '5 20 30'
    block_id = 8
  []
  [rename] # seems to be needed for generated shoebox!!!
    type = RenameBoundaryGenerator
    input = rename_block8
    old_boundary = 'left right front back top  bottom'
    new_boundary = 'blah blah  blah  blah blah blah'
  []
  [boundary_tags]
    type = SideSetsFromNormalsGenerator
    fixed_normal = true
    input = rename
    new_boundary = 'left  right   front   back   top   bottom'
    normals =    '0 0 -1  0 0 1  -1 0 0  1 0 0  0 1 0  0 -1 0'
    replace = true
  []
[]

###########################################################################################################
# Variables
###########################################################################################################

[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_z]
    order = FIRST
    family = LAGRANGE
  [../]
[]

#########################################################################################################
# Kernels
#########################################################################################################

[Kernels]
  [SolidMechanics]
    displacements = 'disp_x disp_y disp_z'
    use_displaced_mesh = true
  [../]
[]

#######################################################################################################
# BCs
#######################################################################################################

[BCs]
  [symmx]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
  [symmy]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []  
  [symmz]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0
  []
  [symmz2]
    type = DirichletBC
    variable = disp_z
    boundary = top
    value = 0
  []
  [tdisp]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = top
    function = '3e-9*t'
  []
[]

#######################################################################################################
# Materials
#######################################################################################################

[Materials]
  [./kelvin_voigt_hard]
    type = GeneralizedKelvinVoigtModel
    creep_modulus = '10e9 10e9'
    creep_viscosity = '1e22 1e23'
    poisson_ratio = 0.2
    young_modulus = 10e9
    block = 0
  [../]
  [./stress_hard]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'creep_hard'
    block = 0
  [../]
  [./creep_hard]
    type = LinearViscoelasticStressUpdate
    block = 0
  [../]
  [./strain_hard]
    type = ComputeFiniteStrain
    displacements = 'disp_x disp_y disp_z'
    block = 0
  [../]

  [./kelvin_voigt_soft]
    type = GeneralizedKelvinVoigtModel
    creep_modulus = '10e9 10e9'
    creep_viscosity = '0.9e22 9e23'
    poisson_ratio = 0.2
    young_modulus = 10e9
    block = '1 2 3 4 5 6 7 8'
  [../]
  [./stress_soft]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'creep_soft'
    block = '1 2 3 4 5 6 7 8'
  [../]
  [./creep_soft]
    type = LinearViscoelasticStressUpdate
    block = '1 2 3 4 5 6 7 8'
  [../]
  [./strain_soft]
    type = ComputeFiniteStrain
    displacements = 'disp_x disp_y disp_z'
    block = '1 2 3 4 5 6 7 8'
  [../]
[]

########################################################################################################
# UserObjects
########################################################################################################

[UserObjects]
  [./update_hard]
    type = LinearViscoelasticityManager
    viscoelastic_model = kelvin_voigt_hard
    block = 0
  [../]
  [./update_soft]
    type = LinearViscoelasticityManager
    viscoelastic_model = kelvin_voigt_soft
    block = '1 2 3 4 5 6 7 8'
  [../]
[]

#######################################################################################################
# Executioner
#######################################################################################################

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart -ksp_max_it'
  petsc_options_value = ' asm      2              lu            gmres     200   20'

  dt = 1e7
  dtmin = 1e6
  dtmax = 1e9
  end_time = 1e10
[]

#######################################################################################################
# Outputs
#######################################################################################################

[Outputs]
  file_base = visco_finite_strain_out
  exodus = true
[]