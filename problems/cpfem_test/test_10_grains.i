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
    nx = 3
    ny = 12
    nz = 12
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
    block = '0 3 5 8'
  []
  [copper_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = '0 3 5 8'
  []
  [brass_gss]
    order = CONSTANT
    family = MONOMIAL
    block = '1 4 7'
  []
  [brass_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = '1 4 7'
  []
  [steel_gss]
    order = CONSTANT
    family = MONOMIAL
    block = '2 6 9'
  []
  [steel_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = '2 6 9'
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
    block = '0 3 5 8'
    base_name = copper
  []
  [brass]
    strain = FINITE
    incremental = true
    add_variables = true
    generate_output = stress_zz
    block = '1 4 7'
    base_name = brass
  []
  [steel]
    strain = FINITE
    incremental = true
    add_variables = true
    generate_output = stress_zz
    block = '2 6 9'
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
    block = '0 3 5 8'
    execute_on = timestep_end
  []
  [slip_inc_copper]
    type = MaterialStdVectorAux
    variable = copper_slip_increment
    property = copper_slip_increment
    index = 0
    block = '0 3 5 8'
    execute_on = timestep_end
  []
  [gss_brass]
    type = MaterialStdVectorAux
    variable = brass_gss
    property = brass_slip_resistance
    index = 0
    block = '1 4 7'
    execute_on = timestep_end
  []
  [slip_inc_brass]
    type = MaterialStdVectorAux
    variable = brass_slip_increment
    property = brass_slip_increment
    index = 0
    block = '1 4 7'
    execute_on = timestep_end
  []
  [gss_steel]
    type = MaterialStdVectorAux
    variable = steel_gss
    property = steel_slip_resistance
    index = 0
    block = '2 6 9'
    execute_on = timestep_end
  []
  [slip_inc_steel]
    type = MaterialStdVectorAux
    variable = steel_slip_increment
    property = steel_slip_increment
    index = 0
    block = '2 6 9'
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
    function = '-0.005*t'
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
    block = '0 3 5 8'
  []
  [stress_copper]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl_copper'
    tan_mod_type = exact
    base_name = copper
    block = '0 3 5 8'
  []
  [trial_xtalpl_copper]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 2
    slip_sys_file_name = input_slip_sys_2.txt
    base_name = copper
    block = '0 3 5 8'
  []
  [twin_only_xtalpl_copper]
    type = CrystalPlasticityTwinningKalidindiUpdate
    number_slip_systems = 2
    slip_sys_file_name = 'fcc_input_twinning_systems_2.txt'
    initial_twin_lattice_friction = 3.0
    non_coplanar_coefficient_twin_hardening = 8e5
    coplanar_coefficient_twin_hardening = 8e4
    block = '0 3 5 8'
  []
  [elasticity_tensor_brass]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9
    euler_angle_1 = 0.0
    euler_angle_2 = 45.0
    euler_angle_3 = 0.9
    base_name = brass
    block = '1 4 7'
  []
  [stress_brass]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl_brass'
    tan_mod_type = exact
    base_name = brass
    block = '1 4 7'
  []
  [trial_xtalpl_brass]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 2
    slip_sys_file_name = input_slip_sys_2.txt
    base_name = brass
    block = '1 4 7'
  []
  [twin_only_xtalpl_brass]
    type = CrystalPlasticityTwinningKalidindiUpdate
    number_slip_systems = 2
    slip_sys_file_name = 'fcc_input_twinning_systems_2.txt'
    initial_twin_lattice_friction = 3.0
    non_coplanar_coefficient_twin_hardening = 8e5
    coplanar_coefficient_twin_hardening = 8e4
    block = '1 4 7'
  []
  [elasticity_tensor_steel]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.7e5 1.3e5 1.3e5 1.7e5 1.3e5 1.7e5 0.8e5 0.8e5 0.8e5'
    fill_method = symmetric9
    base_name = steel
    block = '2 6 9'
  []
  [stress_steel]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl_steel'
    tan_mod_type = exact
    base_name = steel
    block = '2 6 9'
  []
  [trial_xtalpl_steel]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 2
    slip_sys_file_name = input_slip_sys_2.txt
    base_name = steel
    block = '2 6 9'
  []
  [twin_only_xtalpl_steel]
    type = CrystalPlasticityTwinningKalidindiUpdate
    number_slip_systems = 2
    slip_sys_file_name = 'fcc_input_twinning_systems_2.txt'
    initial_twin_lattice_friction = 3.0
    non_coplanar_coefficient_twin_hardening = 8e5
    coplanar_coefficient_twin_hardening = 8e4
    block = '2 6 9'
  []
[]

######################################################################################################
# Postprocessors
######################################################################################################

[Postprocessors]
  [copper_stress_zz]
    type = ElementAverageValue
    variable = copper_stress_zz
    block = '0 3 5 8'
  []
  [brass_stress_zz]
    type = ElementAverageValue
    variable = brass_stress_zz
    block = '1 4 7'
  []
  [steel_stress_zz]
    type = ElementAverageValue
    variable = brass_stress_zz
    block = '2 6 9'
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
    block = '0 3 5 8'
  []
  [copper_slip_increment]
    type = ElementAverageValue
    variable = copper_slip_increment
    block = '0 3 5 8'
  []
  [brass_gss]
    type = ElementAverageValue
    variable = brass_gss
    block = '1 4 7'
  []
  [brass_slip_increment]
    type = ElementAverageValue
    variable = brass_slip_increment
    block = '1 4 7'
  []
  [steel_gss]
    type = ElementAverageValue
    variable = steel_gss
    block = '2 6 9'
  []
  [steel_slip_increment]
    type = ElementAverageValue
    variable = steel_slip_increment
    block = '2 6 9'
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
  solve_type = 'NEWTON'

  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart -ksp_max_it'
  petsc_options_value = ' asm      2              lu            gmres     200   15'
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_abs_step_tol = 1e-8

  dt = 0.1
  dtmin = 0.05
  dtmax = 10.0
  end_time = 12
[]

######################################################################################################
# Outputs
######################################################################################################

[Outputs]
  exodus = true
  perf_graph = true
[]