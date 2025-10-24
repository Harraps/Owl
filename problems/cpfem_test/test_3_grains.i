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
    nx = 2
    ny = 3
    nz = 10
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1.5
    zmin = 0
    zmax = 2
  []
  [rename_block1]
    type = SubdomainBoundingBoxGenerator
    input = whole_mesh
    bottom_left = '0 0 0'
    top_right = '1 1 1'
    block_id = 1
  []
  [rename_block2]
    type = SubdomainBoundingBoxGenerator
    input = rename_block1
    bottom_left = '0 0 1'
    top_right = '1 1 2'
    block_id = 2
  []
  [rename] # seems to be needed for generated shoebox!!!
    type = RenameBoundaryGenerator
    input = rename_block2
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
# [Mesh]
#   [copper]
#     type = GeneratedMeshGenerator
#     dim = 3
#     elem_type = HEX8
#     nx = 2
#     ny = 6
#     nz = 10
#   []
#   [copper_id]
#     type = SubdomainIDGenerator
#     input = copper
#     subdomain_id = 0
#   []
#   [brass]
#     type = GeneratedMeshGenerator
#     dim = 3
#     zmax = 2
#     zmin = 1
#     nx = 2
#     ny = 6
#     nz = 10
#     elem_type = HEX8
#   []
#   [brass_id]
#     type = SubdomainIDGenerator
#     input = brass
#     subdomain_id = 1
#   []
#   [steel]
#     type = GeneratedMeshGenerator
#     dim = 3
#     zmax = 2
#     zmin = 0
#     ymin = 1
#     ymax = 1.5
#     nx = 2
#     ny = 3
#     nz = 20
#     elem_type = HEX8
#   []
#   [steel_id]
#     type = SubdomainIDGenerator
#     input = steel
#     subdomain_id = 2
#   []
#   [sticher]
#     type = StitchedMeshGenerator
#     inputs = 'copper_id brass_id steel_id'
#     stitch_boundaries_pairs = 'front back; bottom top'
#     prevent_boundary_ids_overlap = false
#   []
# []

######################################################################################################
# Aux Variables
######################################################################################################

[AuxVariables]
  [pk2]
    order = CONSTANT
    family = MONOMIAL
  []
  [fp_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [e_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [copper_gss]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  []
  [copper_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  []
  [brass_gss]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [brass_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [steel_gss]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
  [steel_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
[]

######################################################################################################
# Variables
######################################################################################################

[Physics/SolidMechanics/QuasiStatic]
  [copper]
    strain = FINITE
    incremental = true
    add_variables = true
    generate_output = stress_zz
    block = 0
    base_name = copper
  []
  [brass]
    strain = FINITE
    incremental = true
    add_variables = true
    generate_output = stress_zz
    block = 1
    base_name = brass
  []
  [steel]
    strain = FINITE
    incremental = true
    add_variables = true
    generate_output = stress_zz
    block = 2
    base_name = steel
  []
[]

######################################################################################################
# Aux Kernels
######################################################################################################

[AuxKernels]
  [pk2]
    type = RankTwoAux
    variable = pk2
    rank_two_tensor = second_piola_kirchhoff_stress
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
  [fp_zz]
    type = RankTwoAux
    variable = fp_zz
    rank_two_tensor = plastic_deformation_gradient
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
  [e_zz]
    type = RankTwoAux
    variable = e_zz
    rank_two_tensor = total_lagrangian_strain
    index_j = 2
    index_i = 2
    execute_on = timestep_end
  []
  [gss_copper]
    type = MaterialStdVectorAux
    variable = copper_gss
    property = copper_slip_resistance
    index = 0
    block = 0
    execute_on = timestep_end
  []
  [slip_inc_copper]
    type = MaterialStdVectorAux
    variable = copper_slip_increment
    property = copper_slip_increment
    index = 0
    block = 0
    execute_on = timestep_end
  []
  [gss_brass]
    type = MaterialStdVectorAux
    variable = brass_gss
    property = brass_slip_resistance
    index = 0
    block = 1
    execute_on = timestep_end
  []
  [slip_inc_brass]
    type = MaterialStdVectorAux
    variable = brass_slip_increment
    property = brass_slip_increment
    index = 0
    block = 1
    execute_on = timestep_end
  []
  [gss_steel]
    type = MaterialStdVectorAux
    variable = steel_gss
    property = steel_slip_resistance
    index = 0
    block = 2
    execute_on = timestep_end
  []
  [slip_inc_steel]
    type = MaterialStdVectorAux
    variable = steel_slip_increment
    property = steel_slip_increment
    index = 0
    block = 2
    execute_on = timestep_end
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
  [tdisp]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = top
    function = '-0.1*t'
  []
[]

######################################################################################################
# Materials
######################################################################################################

[Materials]
  [elasticity_tensor_copper]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9
    base_name = copper
    block = 0
  []
  [stress_copper]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl_copper'
    tan_mod_type = exact
    base_name = copper
    block = 0
  []
  [trial_xtalpl_copper]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = input_slip_sys.txt
    base_name = copper
    block = 0
  []
  [elasticity_tensor_brass]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9
    euler_angle_1 = 0.0
    euler_angle_2 = 45.0
    euler_angle_3 = 0.9
    base_name = brass
    block = 1
  []
  [stress_brass]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl_brass'
    tan_mod_type = exact
    base_name = brass
    block = 1
  []
  [trial_xtalpl_brass]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = input_slip_sys.txt
    base_name = brass
    block = 1
  []
  [elasticity_tensor_steel]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.7e5 1.3e5 1.3e5 1.7e5 1.3e5 1.7e5 0.8e5 0.8e5 0.8e5'
    fill_method = symmetric9
    base_name = steel
    block = 2
  []
  [stress_steel]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl_steel'
    tan_mod_type = exact
    base_name = steel
    block = 2
  []
  [trial_xtalpl_steel]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = input_slip_sys.txt
    base_name = steel
    block = 2
  []
[]

######################################################################################################
# Postprocessors
######################################################################################################

[Postprocessors]
  [copper_stress_zz]
    type = ElementAverageValue
    variable = copper_stress_zz
    block = 0
  []
  [brass_stress_zz]
    type = ElementAverageValue
    variable = brass_stress_zz
    block = 1
  []
  [steel_stress_zz]
    type = ElementAverageValue
    variable = brass_stress_zz
    block = 2
  []
  [pk2]
    type = ElementAverageValue
    variable = pk2
  []
  [fp_zz]
    type = ElementAverageValue
    variable = fp_zz
  []
  [e_zz]
    type = ElementAverageValue
    variable = e_zz
  []
  [copper_gss]
    type = ElementAverageValue
    variable = copper_gss
    block = 0
  []
  [copper_slip_increment]
    type = ElementAverageValue
    variable = copper_slip_increment
    block = 0
  []
  [brass_gss]
    type = ElementAverageValue
    variable = brass_gss
    block = 1
  []
  [brass_slip_increment]
    type = ElementAverageValue
    variable = brass_slip_increment
    block = 1
  []
  [steel_gss]
    type = ElementAverageValue
    variable = steel_gss
    block = 2
  []
  [steel_slip_increment]
    type = ElementAverageValue
    variable = steel_slip_increment
    block = 2
  []
[]

######################################################################################################
# Preconditioning
######################################################################################################

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

######################################################################################################
# Executioner
######################################################################################################

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-10
  nl_abs_step_tol = 1e-10

  dt = 0.05
  dtmin = 0.01
  dtmax = 10.0
  num_steps = 100
[]

######################################################################################################
# Outputs
######################################################################################################

[Outputs]
  exodus = true
  perf_graph = true
[]
