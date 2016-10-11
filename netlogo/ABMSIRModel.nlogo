;;
;; ============================================================================
;;  Part of  : Agent-Based SIR Model in NetLogo
;;  Created  : 21.01.2012 by Kishoj Bajracharya
;; ============================================================================
;;/

;; global variables
globals [
  ;; Total number of days passed since simulation started 
  gDay 
  ;; Total number of susceptible agents
  gSusceptible 
  ;; Total number of infected agents
  gInfected
  ;; Total number of recovered agents
  gRecovered
  ;; infection radius
  gInfectionRadius 
  ;; Total number of agents
  gPopulation 
  ;; Peak number of infected agents
  gpeak-infected
  ;; #Days when there was peak number of infected agents
  gpeak-day
  ;; Peak infection rate
  gpeak-infection-percentage
]

;; Agent contains some properties
turtles-own [
  health-state 
  Infected-Days 
  had-infection?
  immune?
]

;; Function to set the value of global variable gDay
to set-Days [aDays]
  set gDay aDays
end

;; Function to set the Population of agents
to set-Population [aPopulation]
  ;; Create turtles or agents with Population size = aPopulation
  create-turtles aPopulation
  ;; Set the initial parameters for each agent
  ask turtles [
    ;; Set the shape of an agent as person
    set shape "person"
    ;; Set the size of the agent
    set size 1.5
    ;; Locate agents into different RANDOM positions on space.
    setxy random-xcor random-ycor        
    ;; Select a random direction for an agent
    set heading random 360                
    ;; Set the initial health-state of each agents as susceptible
    set health-state "S"       
    ;; Infected-Days := 0 implies all population are susceptible to disease. 
    set Infected-Days 0       
    ;; Set the agent with no infection at beginning 
    set had-infection? false   
    ;; Set the agent with no immune at beginning            
    set immune? false
    ;; Set the color of agents 
    set-agent-color
    ;; Set the label of agents 
    setLabel
  ] 
end

;; Function to set the infected agents in Population
to set-Infected-Agents [aInfected]
  ;; start infections until we get desired Infected agents
  repeat aInfected [  
    ;; Make an susceptible agent infectious 
    ask one-of turtles with [health-state = "S"] [
      ;; Call function to infect agents
      become-infectious
    ]
  ]
  ;; set agent color
  ask turtles [    
    set-agent-color
  ]
end

;; Initialize the parameters for model like Days, Population size, Infected agent size
to initialize-parameters-for-model [aDays aPopulation aInfected ] 
  set gDay aDays  
  set gPopulation aPopulation 
  set gInfected aInfected
  set gpeak-infected gInfected
end

;; Function to set the Population containing Infected agents
to setup-Population-with-Infection
  set-Population gPopulation 
  set-Infected-Agents gInfected
end

;; Initial setup for running the model
to setup
  ;; Clear all turtles or agents
  clear-all
  ;; Constraints
  if Infected > Population  
  [
    ;; Display message for termination of simulation
    user-message (word "Number of Infected agents cannot be more than population!.")
    ;; stops the simulation
    stop 
  ]
  ;; Initialize parameters for model
  initialize-parameters-for-model 0 Population Infected 
  ;; Setup Population containing Infected agents on model
  setup-Population-with-Infection 
  ;; Consume their dynamic statistics
  consume-statistics-from-model 
  ;; Setup the file for writing statistics on a file
  check-and-setup-file 
end

;; Run our model continuously
to go
  ;; stop when there are no infectious and no recovering agents
  if gInfected = 0  
  [
    ;; Display message for termination of simulation
    user-message (word "This simulation is terminated!!!.")
    ;; stops the simulation
    stop 
  ]
  ;; call the step function for executing the model once.
  step
end

 ;; function for executing the model once.
to step
  ; Increment day by one
  set gDay gDay + 1
  ; Increment the tick 
  tick
  ; Move each agent
  move-agents
  ; Agents interaction
  agents-interaction  
  ; Update the health-state of each agent
  update-health-states-of-agents
  ; Get statistics  
  consume-statistics-from-model
  ; Draw graphs
  draw-graphs-plots
  ; Plot histogram
  draw-histogram
  ; Write to a file  
  write-result-to-file
end

;; function to interact agents in ABM
to agents-interaction
  ; Infected agent transfers disease to suceptible agents 
  ask turtles [
     if health-state = "I" [
      ask one-of turtles-here in-radius Infection-Radius [
         if health-state = "S" [
           become-infectious
        ]
      ]
    ]
  ]  
end

;; function to infect susceptible agent
to become-infectious
  ;; set health-state to "I"
  set health-state "I"
  ;; set the boolean flag had-infection? to true
  set had-infection? true
end

;; function to move agents randomly 
to move-agents
  ask turtles [
    ;; move only agents with health-state = S or I or R since dead agents doesnot move.
    if health-state = "S" or health-state = "I" or health-state = "R"
    [
      right random 45
      left random 45
      ;; move by one step
      forward 1
    ]
  ]
end

;; function to update health states of each agents
to update-health-states-of-agents
  ask turtles [
    ;; If agent have health-state I or R then increment the value of Infected-Days by 1.
    if health-state = "I" or health-state = "R" [
      set Infected-Days Infected-Days + 1
    ]
    ;; If the Infected-Days of agent is greater than Infectious-Days then the agent recovers
    if Infected-Days > Infectious-Days [
        if health-state = "I" [
          set health-state "R"
          set had-infection? false
        ]
   ]
   
   set-agent-color
  ]
end

;; function to set the color of an agent based on their health-state
to set-agent-color
  if health-state = "S" [ set color yellow ]
  if health-state = "I" [ set color red ]
  if health-state = "R" [ set color green ]
  setLabel
end


;; funciton to collect epidemic statistics 
to consume-statistics-from-model 
  set gSusceptible (count turtles with [health-state = "S"])
  set gInfected (count turtles with [health-state = "I"])
  set gRecovered (count turtles with [health-state = "R"])
  if gInfected > gpeak-infected [
    set gpeak-infected gInfected
    set gpeak-day gDay
    set gpeak-infection-percentage %infected
  ]   
end

;; function to label the state of an agent 
to setLabel
  if health-state = "S" [
       set label "S"
  ]
  if health-state = "I" [
       set label "I"
  ]
  if health-state = "R" [
       set label "R"
  ]
end

;; function to write the statistics of dynamic model on a file.
to write-result-to-file
  ; if nothing to write then  stop
  if empty? Result-File [stop]
  ; Open file
  file-open Result-File
  ; Write into the file
  file-print (word gDay "," gSusceptible "," gInfected "," gRecovered "," gpeak-infected "," gpeak-day "," gpeak-infection-percentage "," %susceptible "," %infected "," %Recovered)
  ; Close file
  file-close
end

;; function to check and setup the file.
to check-and-setup-file
  if not empty? Result-File [
    ; Check if file exists in the locationi
    if file-exists? Result-File [
      ; if yes delete the existing file 
      file-delete Result-File 
    ]
  ]
end

;; function to plot the graphs 
to draw-graphs-plots
  set-current-plot "Graph plots"
  set-current-plot-pen "Susceptible"
  plot 100 * gSusceptible / gPopulation
  set-current-plot-pen "Infected"
  plot 100 * gInfected / gPopulation
  set-current-plot-pen "Recovered"
  plot 100 * gRecovered / gPopulation
end

;; function to draw the histogram
to draw-histogram
  set-current-plot "Histogram"
  plot-pen-reset
  set-plot-pen-color yellow
  plot 100 * gSusceptible / gPopulation
  set-plot-pen-color red
  plot 100 * gInfected / gPopulation
  set-plot-pen-color green
  plot 100 * gRecovered / gPopulation
end

;; function to report susceptible percentage
to-report %susceptible
  ifelse any? turtles
    [ report (gSusceptible / count turtles) * 100 ]
    [ report 0 ]
end  

;; function to report infected percentage
to-report %infected
  ifelse any? turtles
    [ report (count turtles with [had-infection?] / count turtles) * 100 ]
    [ report 0 ]
end

;; function to report recovered percentage
to-report %recovered
  ifelse any? turtles
    [ report (gRecovered / count turtles) * 100 ]
    [ report 0 ]
end












  

@#$#@#$#@
GRAPHICS-WINDOW
293
32
832
426
25
17
10.373
1
10
1
1
1
0
1
1
1
-25
25
-17
17
0
0
1
ticks

CC-WINDOW
5
509
1271
604
Command Center
0

BUTTON
100
237
163
270
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
99
285
162
318
NIL
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
179
285
243
318
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
189
448
258
493
I
gInfected\n
17
1
11

MONITOR
260
449
317
494
R
gRecovered
17
1
11

MONITOR
67
447
124
492
#Days
gDay
17
1
11

SLIDER
90
36
262
69
Population
Population
0
1000
300
1
1
NIL
HORIZONTAL

SLIDER
90
73
262
106
Infected
Infected
0
1000
10
1
1
NIL
HORIZONTAL

SLIDER
90
113
262
146
Infection-Radius
Infection-Radius
0
5
1
1
1
NIL
HORIZONTAL

SLIDER
90
152
262
185
Infectious-Days
Infectious-Days
0
100
34
1
1
NIL
HORIZONTAL

INPUTBOX
124
362
205
422
Result-File
output.csv
1
0
String

PLOT
867
34
1261
272
Graph plots
Days
Population Percentage
0.0
100.0
0.0
100.0
true
true
PENS
"Susceptible" 1.0 0 -1184463 true
"Infected" 1.0 0 -2674135 true
"Recovered" 1.0 0 -10899396 true

MONITOR
681
450
767
495
% Infected
%infected
2
1
11

MONITOR
769
449
858
494
% Recovered
%Recovered\n
2
1
11

BUTTON
180
237
243
270
Clear
Clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
109
11
259
30
INPUT PARAMETERS\n
15
15.0
1

TEXTBOX
134
213
284
232
CONTROLS
15
16.0
1

TEXTBOX
544
10
694
30
SPACE
16
15.0
1

TEXTBOX
119
339
269
358
OUTPUT FILE
15
15.0
1

TEXTBOX
465
429
615
448
OUTPUTS
15
15.0
1

MONITOR
413
450
478
495
Peak Day
gpeak-day
4
1
11

MONITOR
320
449
410
494
Peak Infected
gpeak-infected
2
1
11

MONITOR
481
450
584
495
Peak %Infected
gpeak-infection-percentage
2
1
11

PLOT
867
273
1262
495
Histogram
Class of Population
Population Percentage
0.0
10.0
0.0
100.0
true
true
PENS
"Susceptible" 2.0 1 -1184463 true
"Infected" 1.0 0 -2674135 true
"Recovered" 1.0 0 -10899396 true

MONITOR
586
450
678
495
% Susceptible
%susceptible
2
1
11

MONITOR
128
447
185
492
S
gSusceptible
2
1
11

TEXTBOX
1027
10
1177
29
CHARTS
15
15.0
1

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
