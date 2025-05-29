[DynamicSelector]

├── [Sequence] React To Enemy
│    └── [CheckAgentProperty] 
│         property: "is_enemy_nearby" 
│         value: true

├── [Sequence] Chase Target
│    ├── [InRange] 
│         range: (0, 9) 
│         of: target
│    ├── [PlayAnimation] 
│         animation: "Walk"
│    └── [ChaseTarget]

├── [Sequence] Attack Player
│    ├── [PlayAnimation] 
│         animation: "Punch_Jab"
│    ├── [ConsolePrint] 
│         text: "ATTACK"
│    └── [AwaitAnimation] 
│         animation: "Punch_Jab" 
│         max_time: 1.0s

├── [Sequence] Wander
│    ├── [Sequence] Pause Before Action
│    │    ├── [PlayAnimation] 
│    │         animation: "Idle"
│    │    └── [Wait] 
│             time: 0.2 to 0.5s
│    ├── [PlayAnimation] 
│         animation: "Walk"
│    └── [Wait] 
│         time: 2.0 to 4.0s

└── [Sequence] Idle
     ├── [PlayAnimation] 
     │    animation: "Idle"
     └── [Wait] 
          time: 2.0 to 4.0s
