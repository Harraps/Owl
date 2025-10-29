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
    nx = 6
    ny = 24
    nz = 24
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 6
    zmin = 0
    zmax = 6
  []
  [rename_block1]
    type = SubdomainBoundingBoxGenerator
    input = whole_mesh
    bottom_left = '0 0 0'
    top_right = '1 2 4'
    block_id = 1
  []
  [rename_block2]
    type = SubdomainBoundingBoxGenerator
    input = rename_block1
    bottom_left = '0 0 4'
    top_right = '1 2 6'
    block_id = 2
  []
    [rename_block3]
    type = SubdomainBoundingBoxGenerator
    input = rename_block2
    bottom_left = '0 2 0'
    top_right = '1 3 1'
    block_id = 3
  []
  [rename_block4]
    type = SubdomainBoundingBoxGenerator
    input = rename_block3
    bottom_left = '0 2 1'
    top_right = '1 3 3'
    block_id = 4
  []
  [rename_block5]
    type = SubdomainBoundingBoxGenerator
    input = rename_block4
    bottom_left = '0 2 3'
    top_right = '1 3 6'
    block_id = 5
  []
  [rename_block6]
    type = SubdomainBoundingBoxGenerator
    input = rename_block5
    bottom_left = '0 3 0'
    top_right = '1 4 2'
    block_id = 6
  []
  [rename_block7]
    type = SubdomainBoundingBoxGenerator
    input = rename_block6
    bottom_left = '0 3 2'
    top_right = '1 4 6'
    block_id = 7
  []
  [rename_block8]
    type = SubdomainBoundingBoxGenerator
    input = rename_block7
    bottom_left = '0 4 0'
    top_right = '1 6 1'
    block_id = 8
  []
  [rename_block9]
    type = SubdomainBoundingBoxGenerator
    input = rename_block8
    bottom_left = '0 4 1'
    top_right = '1 6 5'
    block_id = 9
  []
  [rename] # seems to be needed for generated shoebox!!!
    type = RenameBoundaryGenerator
    input = rename_block9
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
    generate_output = 'stress_yy elastic_strain_yy creep_strain_yy plastic_strain_yy'
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
    function = '6e-10*t'
  []
[]

######################################################################################################
# Materials
######################################################################################################

[Materials]
  [elasticity_tensor_copper]
    type = ComputeIsotropicElasticityTensor
    block = '0 3 5 8'
    youngs_modulus = 9e10
    poissons_ratio = 0.33
  []
  [creep_plas_copper]
    type = ComputeCreepPlasticityStress
    block = '0 3 5 8'
    tangent_operator = elastic
    creep_model = creep_copper
    plasticity_model = plasticity_copper
    max_iterations = 50
    relative_tolerance = 1e-8
    absolute_tolerance = 1e-8
  []
  [creep_copper]
    type = PowerLawCreepStressUpdate
    block = '0 3 5 8'
    coefficient = 8e-36
    n_exponent = 3
    activation_energy = 0
    temperature = 1
  []
  [plasticity_copper]
    type = IsotropicPlasticityStressUpdate
    block = '0 3 5 8'
    yield_stress = 20e30
    hardening_constant = 0
  []

  [elasticity_tensor_brass]
    type = ComputeIsotropicElasticityTensor
    block = '1 4 7'
    youngs_modulus = 1.3e11
    poissons_ratio = 0.3
  []
  [creep_plas_brass]
    type = ComputeCreepPlasticityStress
    block = '1 4 7'
    tangent_operator = elastic
    creep_model = creep_brass
    plasticity_model = plasticity_brass
    max_iterations = 50
    relative_tolerance = 1e-8
    absolute_tolerance = 1e-8
  []
  [creep_brass]
    type = PowerLawCreepStressUpdate
    block = '1 4 7'
    coefficient = 1e-35
    n_exponent = 3
    activation_energy = 0
    temperature = 1
  []
  [plasticity_brass]
    type = IsotropicPlasticityStressUpdate
    block = '1 4 7'
    yield_stress = 20e30
    hardening_constant = 0
  []

  [elasticity_tensor_steel]
    type = ComputeIsotropicElasticityTensor
    block = '2 6 9'
    youngs_modulus = 1e10
    poissons_ratio = 0.28
  []
  [creep_plas_steel]
    type = ComputeCreepPlasticityStress
    block = '2 6 9'
    tangent_operator = elastic
    creep_model = creep_steel
    plasticity_model = plasticity_steel
    max_iterations = 50
    relative_tolerance = 1e-8
    absolute_tolerance = 1e-8
  []
  [creep_steel]
    type = PowerLawCreepStressUpdate
    block = '2 6 9'
    coefficient = 2e-35
    n_exponent = 3 
    activation_energy = 0
    temperature = 1
  []
  [plasticity_steel]
    type = IsotropicPlasticityStressUpdate
    block = '2 6 9'
    yield_stress = 20e30
    hardening_constant = 0
  []
[]

######################################################################################################
# Executioner
######################################################################################################

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart -ksp_max_it'
  petsc_options_value = ' asm      2              lu            gmres     200   15'
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_abs_step_tol = 1e-8

  dt = 5e7
  dtmin = 2e7
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