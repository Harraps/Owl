[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

######################################################################################################
# Mesh 
######################################################################################################

[Mesh]
  [cube]
    type = GeneratedMeshGenerator
    dim = 3
    elem_type = HEX8
    # Traction test #########################
    # nx = 4
    # ny = 4
    # nz = 6
    # Simple shear test ####################
    nx = 4
    ny = 6
    nz = 4
    xmin = 0
    xmax = 10
    ymin = 0
    ymax = 10
    zmin = 0
    zmax = 10
  []
  [rename] # seems to be needed for generated shoebox!!!
    type = RenameBoundaryGenerator
    input = cube
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
    block = 0
  []
  [copper_slip_increment]
    order = CONSTANT
    family = MONOMIAL
    block = 0
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
[]

######################################################################################################
# BCs
######################################################################################################

# Uniaxial traction with pressure ##############################################################################
# [BCs]
#   [symmx]
#     type = DirichletBC
#     variable = disp_x
#     boundary = left
#     value = 0
#   []
#   [symmy]
#     type = DirichletBC
#     variable = disp_y
#     boundary = left
#     value = 0
#   []  
#   [symmz]
#     type = DirichletBC
#     variable = disp_z
#     boundary = left
#     value = 0
#   []
#   [tdisp]
#     type = Pressure
#     variable = disp_z
#     boundary = right
#     function = traction_pressure
#   []
# []

# Simple shear with pressure #########################################################################################
# [BCs]
#   [symmx]
#     type = DirichletBC
#     variable = disp_x
#     boundary = bottom
#     value = 0
#   []
#   [symmy]
#     type = DirichletBC
#     variable = disp_y
#     boundary = bottom
#     value = 0
#   []  
#   [symmz]
#     type = DirichletBC
#     variable = disp_z
#     boundary = bottom
#     value = 0
#   []
#   [sdisp]
#     type = FunctionNeumannBC
#     variable = disp_z
#     boundary = top
#     function = shear_pressure
#   []
# []

# Uniaxial traction with pressure ##############################################################################
# [BCs]
#   [symmx]
#     type = DirichletBC
#     variable = disp_x
#     boundary = left
#     value = 0
#   []
#   [symmy]
#     type = DirichletBC
#     variable = disp_y
#     boundary = left
#     value = 0
#   []  
#   [symmz]
#     type = DirichletBC
#     variable = disp_z
#     boundary = left
#     value = 0
#   []
#   [tdisp]
#     type = Pressure
#     variable = disp_z
#     boundary = right
#     function = traction_displacement
#   []
# []

# Simple shear with pressure #########################################################################################
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
  [sdisp]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = top
    function = shear_displacement
  []
[]

######################################################################################################
# Functions
######################################################################################################

[Functions]
  [traction_pressure]
    type = PiecewiseLinear
    x = '0 1e8'
    y = '0 -500'
  []
  [shear_pressure]
    type = PiecewiseLinear
    x = '0 1e8 2e8 2.1e8'
    y = '0 30 30 0'
  []
  [traction_displacement]
    type = PiecewiseLinear
    x = '0 1e8'
    y = '0 1'
  []
  [shear_displacement]
    type = PiecewiseLinear
    x = '0 1e5'
    y = '0 -2'
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
  solve_type = PJFNK

  petsc_options_iname = '-pc_type -sub_pc_type -ksp_type -ksp_max_it'
  petsc_options_value = 'asm ilu gmres 10'

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_abs_step_tol = 1e-8

  dt = 1000
  dtmin = 10
  end_time = 1e5
[]

######################################################################################################
# Outputs
######################################################################################################

[Outputs]
  exodus = true
  perf_graph = true
[]
