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

######################################################################################################
# Variables
######################################################################################################

[Physics/SolidMechanics/QuasiStatic]
  [all]
    strain = FINITE
    incremental = true
    add_variables = true
    generate_output = 'stress_yy stress_zz elastic_strain_yy elastic_strain_zz creep_strain_yy creep_strain_zz'
  []
[]

######################################################################################################
# BCs
######################################################################################################

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

######################################################################################################
# Materials
######################################################################################################

[Materials]
  [elasticity_tensor_hard]
    type = ComputeIsotropicElasticityTensor
    block = 0
    youngs_modulus = 1.3e11
    poissons_ratio = 0.33
  []
  [creep_plas_hard]
    type = ComputeCreepPlasticityStress
    block = 0
    tangent_operator = elastic
    creep_model = creep_hard
    plasticity_model = plasticity_hard
    max_iterations = 20
    relative_tolerance = 1e-8
    absolute_tolerance = 1e-8
  []
  [creep_hard]
    type = PowerLawCreepStressUpdate
    block = 0
    coefficient = 1.3e-36
    n_exponent = 3
    activation_energy = 0
    temperature = 1
  []
  [plasticity_hard]
    type = IsotropicPlasticityStressUpdate
    block = 0
    yield_stress = 20e36
    hardening_constant = 0
  []

  [elasticity_tensor_soft]
    type = ComputeIsotropicElasticityTensor
    block = '1 2 3 4 5 6 7 8'
    youngs_modulus = 1e10
    poissons_ratio = 0.3
  []
  [creep_plas_soft]
    type = ComputeCreepPlasticityStress
    block = '1 2 3 4 5 6 7 8'
    tangent_operator = elastic
    creep_model = creep_soft
    plasticity_model = plasticity_soft
    max_iterations = 50
    relative_tolerance = 1e-8
    absolute_tolerance = 1e-8
  []
  [creep_soft]
    type = PowerLawCreepStressUpdate
    block = '1 2 3 4 5 6 7 8'
    coefficient = 1e-36
    n_exponent = 3
    activation_energy = 0
    temperature = 1
  []
  [plasticity_soft]
    type = IsotropicPlasticityStressUpdate
    block = '1 2 3 4 5 6 7 8'
    yield_stress = 20e30
    hardening_constant = 0
  []
[]

######################################################################################################
# Executioner
######################################################################################################

[Executioner]
  type = Transient
  solve_type = 'NEWTON'

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart -ksp_max_it'
  petsc_options_value = ' asm      2              lu            gmres     200   10'

  dt = 1e7
  dtmin = 1e6
  dtmax = 1e9
  end_time = 1e10
[]

######################################################################################################
# Outputs
######################################################################################################

[Outputs]
  exodus = true
  perf_graph = true
[]