[Mesh]
    [gmg]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 100
        ny = 10
        xmax = 0.304
        ymax = 0.0257
    []
    rz_coord_axis = X
    coord_type = RZ
[]

[Problem]
    type = FEProblem
[]

[Variables]
    [pressure]
        order = FIRST
        family = LAGRANGE
    []
[]

[Kernels]
    [diffusion]
        type = ADDiffusion
        variable = pressure
    []
[]

[BCs]
    [inlet]
        type = DirichletBC
        variable = pressure
        boundary = left
        value = 4000
    []
    [outlet]
        type = DirichletBC
        variable = pressure
        boundary = right
        value = 0.0
    []
[]

[Executioner]
    type = Steady
    solve_type = NEWTON
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true
[]