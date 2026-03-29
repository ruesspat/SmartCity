turtles-own [
  adopted?
  satisfied?
  cluster
  attitude
  subjective-norm
  behav-control
  tpb-readiness
  social-threshold
  activation-probability
  is-active?
  initial-adopter?
  adoption-time
]

globals [
  rewiring-probability
  c1-count c2-count c3-count c4-count c5-count
  adopter-c1 adopter-c2 adopter-c3 adopter-c4 adopter-c5
  non-adopter-c1 non-adopter-c2 non-adopter-c3 non-adopter-c4 non-adopter-c5
  active-c1 active-c2 active-c3 active-c4 active-c5
]

to update-activation-status
  let global-adoption-rate count turtles with [adopted? = true] / count turtles
  ask turtles [
    let personal-exposure ifelse-value (count link-neighbors > 0)
      [count link-neighbors with [adopted? = true] / count link-neighbors]
      [0]
    calculate-unified-activation-probability global-adoption-rate personal-exposure
    if not is-active? [
      if random-float 1 < activation-probability [
        set is-active? true
      ]
    ]
  ]
end

to calculate-unified-activation-probability [global-adoption personal-exposure]
  let global-sensitivity 0
  let personal-sensitivity 0
  if cluster = 1 [
    set global-sensitivity 0.2
    set personal-sensitivity 0.1
  ]
  if cluster = 2 [
    set global-sensitivity 0.4
    set personal-sensitivity 0.5
  ]
  if cluster = 3 [
    set global-sensitivity 0.3
    set personal-sensitivity 0.7
  ]
  if cluster = 4 [
    set global-sensitivity 0.6
    set personal-sensitivity 0.8
  ]
  if cluster = 5 [
    set global-sensitivity 0.8
    set personal-sensitivity 0.4
  ]
  let base-activation (global-adoption * global-sensitivity) + (personal-exposure * personal-sensitivity)
  let time-factor min list 1.0 (ticks / 400.0)
  if cluster = 1 [
    set base-activation max list base-activation (0.02 + time-factor * 0.5)
  ]
  set activation-probability min list 0.95 max list 0.0 (base-activation * time-factor)
end

to setup
  clear-all
  if not is-number? sharec1 [ set sharec1 2.5 ]
  if not is-number? sharec2 [ set sharec2 13.5 ]
  if not is-number? sharec3 [ set sharec3 34.0 ]
  if not is-number? sharec4 [ set sharec4 34.0 ]
  if not is-number? sharec5 [ set sharec5 16.0 ]
  if not is-number? attitudec1 [ set attitudec1 5.5 ]
  if not is-number? attitudec2 [ set attitudec2 4.8 ]
  if not is-number? attitudec3 [ set attitudec3 4.2 ]
  if not is-number? attitudec4 [ set attitudec4 3.6 ]
  if not is-number? attitudec5 [ set attitudec5 3.0 ]
  if not is-number? sub.normc1 [ set sub.normc1 3.0 ]
  if not is-number? sub.normc2 [ set sub.normc2 3.5 ]
  if not is-number? sub.normc3 [ set sub.normc3 4.0 ]
  if not is-number? sub.normc4 [ set sub.normc4 4.5 ]
  if not is-number? sub.normc5 [ set sub.normc5 4.0 ]
  if not is-number? beh.controlc1 [ set beh.controlc1 5.8 ]
  if not is-number? beh.controlc2 [ set beh.controlc2 5.2 ]
  if not is-number? beh.controlc3 [ set beh.controlc3 4.5 ]
  if not is-number? beh.controlc4 [ set beh.controlc4 3.8 ]
  if not is-number? beh.controlc5 [ set beh.controlc5 3.2 ]
  if not is-number? weight_Attitude [ set weight_Attitude 1.0 ]
  if not is-number? weight_Sub-Norm [ set weight_Sub-Norm 1.0 ]
  if not is-number? weight_behControl [ set weight_behControl 1.0 ]
  if not is-number? num-agents [ set num-agents 100 ]
  if not is-number? empfehlung [ set empfehlung 0.0 ]
  if not is-number? informationskampagnen [ set informationskampagnen 0.0 ]
  if not is-number? funktionserweiterung [ set funktionserweiterung 0.0 ]
  if not is-number? geraetekompatibilitaet [ set geraetekompatibilitaet 0.0 ]
  set rewiring-probability 0.1
  set c1-count round (sharec1 * num-agents / 100)
  set c2-count round (sharec2 * num-agents / 100)
  set c3-count round (sharec3 * num-agents / 100)
  set c4-count round (sharec4 * num-agents / 100)
  set c5-count round (sharec5 * num-agents / 100)
  let total-assigned c1-count + c2-count + c3-count + c4-count + c5-count
  if total-assigned < num-agents [ set c5-count c5-count + (num-agents - total-assigned) ]
  if total-assigned > num-agents [ set c5-count c5-count - (total-assigned - num-agents) ]
  create-cluster-agents 1 c1-count attitudec1 sub.normc1 beh.controlc1
  create-cluster-agents 2 c2-count attitudec2 sub.normc2 beh.controlc2
  create-cluster-agents 3 c3-count attitudec3 sub.normc3 beh.controlc3
  create-cluster-agents 4 c4-count attitudec4 sub.normc4 beh.controlc4
  create-cluster-agents 5 c5-count attitudec5 sub.normc5 beh.controlc5
  make-small-worlds-links
  if count turtles > 0 [
    let innovators turtles with [cluster = 1]
    let initial-adopter-count max list 1 round (count innovators * 0.4)
    if count innovators >= initial-adopter-count [
      ask n-of initial-adopter-count innovators [
        set adopted? true
        set satisfied? true
        set initial-adopter? true
        set adoption-time 0
        set is-active? true
        set color green
      ]
    ]
  ]
  clear-all-plots
  initialize-custom-plots
  update-adopter-monitors
  update-activation-monitors
  reset-ticks
end

to create-cluster-agents [cluster-num num-agents-in-cluster att-val norm-val control-val]
  if num-agents-in-cluster > 0 [
    create-turtles num-agents-in-cluster [
      setxy random-xcor random-ycor
      set adopted? false
      set satisfied? false
      set initial-adopter? false
      set adoption-time -1
      set shape "person"
      set color red
      set cluster cluster-num
      set attitude (att-val + random-normal 0 1.0) * 0.85
      set subjective-norm (norm-val + random-normal 0 1.0) * 0.85
      set behav-control (control-val + random-normal 0 1.0) * 0.85
      set attitude max list 1 min list 7 attitude
      set subjective-norm max list 1 min list 7 subjective-norm
      set behav-control max list 1 min list 7 behav-control
      if cluster-num = 1 [ set social-threshold 0.05 ]
      if cluster-num = 2 [ set social-threshold 0.20 ]
      if cluster-num = 3 [ set social-threshold 0.45 ]
      if cluster-num = 4 [ set social-threshold 0.65 ]
      if cluster-num = 5 [ set social-threshold 0.85 ]
      set activation-probability 0
      set is-active? false
      if cluster-num = 1 [ set is-active? true ]
      calculate-tpb-readiness
    ]
  ]
end

to go
  update-activation-status
  ask turtles [
    if is-active? [ make-adoption-decision ]
  ]
  update-adopter-monitors
  update-activation-monitors
  update-plot
  tick
end

to make-adoption-decision
  if not adopted? [
    calculate-tpb-readiness
    let adoption-probability calculate-adoption-probability
    if random-float 1 < adoption-probability [
      set adopted? true
      set satisfied? true
      set adoption-time ticks
      set color green
    ]
  ]
  if adopted? and not initial-adopter? and random-float 1 < 0.005 [
    if tpb-readiness < 0.2 [
      set adopted? false
      set adoption-time -1
      set color red
    ]
  ]
end

to calculate-tpb-readiness
  let weighted-attitude attitude * weight_Attitude
  let weighted-norm subjective-norm * weight_Sub-Norm
  let weighted-control behav-control * weight_behControl
  let total-weight weight_Attitude + weight_Sub-Norm + weight_behControl
  let tpb-sum (weighted-attitude + weighted-norm + weighted-control)
  let min-possible total-weight
  let max-possible total-weight * 7
  ifelse max-possible > min-possible
    [ set tpb-readiness (tpb-sum - min-possible) / (max-possible - min-possible) ]
    [ set tpb-readiness 0.5 ]
  apply-environment-interventions
  set tpb-readiness max list 0 min list 1 tpb-readiness
end

to apply-environment-interventions
  let adoption-rate count turtles with [adopted? = true] / num-agents
  let saturation-factor 1 - (adoption-rate ^ 1.5)
  if informationskampagnen > 0 [
    let attitude-boost informationskampagnen * 1.0 * saturation-factor
    if cluster = 1 [ set attitude-boost attitude-boost * 1.3 ]
    if cluster = 2 [ set attitude-boost attitude-boost * 1.2 ]
    if cluster = 3 [ set attitude-boost attitude-boost * 0.9 ]
    if cluster = 5 [ set attitude-boost attitude-boost * 0.6 ]
    set tpb-readiness tpb-readiness * (1 + attitude-boost)
  ]
  if empfehlung > 0 [
    let recommending-neighbors count link-neighbors with [adopted? = true and satisfied? = true]
    let total-neighbors count link-neighbors
    if total-neighbors > 0 [
      let recommendation-strength (recommending-neighbors / total-neighbors) * empfehlung * saturation-factor
      let norm-boost recommendation-strength * 0.4
      if cluster = 2 [ set norm-boost norm-boost * 1.4 ]
      if cluster = 3 [ set norm-boost norm-boost * 1.3 ]
      if cluster = 4 [ set norm-boost norm-boost * 1.2 ]
      if cluster = 1 [ set norm-boost norm-boost * 0.7 ]
      set tpb-readiness tpb-readiness * (1 + norm-boost)
    ]
  ]
  if funktionserweiterung > 0 [
    let function-boost funktionserweiterung * 1.0 * saturation-factor
    if cluster = 1 [ set function-boost function-boost * 1.5 ]
    if cluster = 2 [ set function-boost function-boost * 1.3 ]
    if cluster = 3 [ set function-boost function-boost * 1.0 ]
    if cluster = 4 [ set function-boost function-boost * 0.8 ]
    if cluster = 5 [ set function-boost function-boost * 0.6 ]
    set tpb-readiness tpb-readiness * (1 + function-boost)
  ]
  if geraetekompatibilitaet > 0 [
    let compatibility-boost geraetekompatibilitaet * 0.6 * saturation-factor
    if cluster = 3 [ set compatibility-boost compatibility-boost * 1.3 ]
    if cluster = 4 [ set compatibility-boost compatibility-boost * 1.4 ]
    if cluster = 5 [ set compatibility-boost compatibility-boost * 1.2 ]
    if cluster = 1 [ set compatibility-boost compatibility-boost * 0.8 ]
    set tpb-readiness tpb-readiness * (1 + compatibility-boost)
  ]
end

to-report calculate-adoption-probability
  let adopting-neighbors count link-neighbors with [adopted? = true]
  let total-neighbors count link-neighbors
  let social-pressure 0
  if total-neighbors > 0 [ set social-pressure adopting-neighbors / total-neighbors ]
  let base-probability tpb-readiness * 0.003
  if social-pressure >= social-threshold [
    let social-multiplier (social-pressure - social-threshold) * 4.0
    set base-probability base-probability + social-multiplier
  ]
  if cluster = 1 [ set base-probability base-probability * 1.3 ]
  if cluster = 2 [ set base-probability base-probability * 1.05 ]
  if cluster = 5 [ set base-probability base-probability * 0.7 ]
  report max list 0 min list 0.15 base-probability
end

to make-small-worlds-links
  if count turtles < 4 [
    ask turtles [ create-links-with other turtles ]
    stop
  ]
  ask turtles [
    let my-id who
    let num-turtles count turtles
    let n 1
    repeat 2 [
      let right-neighbor ((my-id + n) mod num-turtles)
      let left-neighbor ((my-id - n + num-turtles) mod num-turtles)
      if not link-neighbor? turtle right-neighbor [ create-link-with turtle right-neighbor ]
      if not link-neighbor? turtle left-neighbor [ create-link-with turtle left-neighbor ]
      set n n + 1
    ]
  ]
  ask links [
    if random-float 1 < rewiring-probability [
      let node1 end1
      let node2 end2
      die
      ask node1 [
        let possible-partners turtles with [self != node1 and not link-neighbor? node1]
        if any? possible-partners [ create-link-with one-of possible-partners ]
      ]
    ]
  ]
end

to initialize-custom-plots
  set-current-plot "AdoptionChart"
  clear-plot
end

to update-adopter-monitors
  if count turtles = 0 [
    set adopter-c1 0 set adopter-c2 0 set adopter-c3 0 set adopter-c4 0 set adopter-c5 0
    set non-adopter-c1 0 set non-adopter-c2 0 set non-adopter-c3 0 set non-adopter-c4 0 set non-adopter-c5 0
    stop
  ]
  set adopter-c1 count turtles with [cluster = 1 and adopted? = true]
  set adopter-c2 count turtles with [cluster = 2 and adopted? = true]
  set adopter-c3 count turtles with [cluster = 3 and adopted? = true]
  set adopter-c4 count turtles with [cluster = 4 and adopted? = true]
  set adopter-c5 count turtles with [cluster = 5 and adopted? = true]
  set non-adopter-c1 count turtles with [cluster = 1 and adopted? = false]
  set non-adopter-c2 count turtles with [cluster = 2 and adopted? = false]
  set non-adopter-c3 count turtles with [cluster = 3 and adopted? = false]
  set non-adopter-c4 count turtles with [cluster = 4 and adopted? = false]
  set non-adopter-c5 count turtles with [cluster = 5 and adopted? = false]
end

to update-activation-monitors
  if count turtles = 0 [
    set active-c1 0 set active-c2 0 set active-c3 0 set active-c4 0 set active-c5 0
    stop
  ]
  set active-c1 count turtles with [cluster = 1 and is-active? = true]
  set active-c2 count turtles with [cluster = 2 and is-active? = true]
  set active-c3 count turtles with [cluster = 3 and is-active? = true]
  set active-c4 count turtles with [cluster = 4 and is-active? = true]
  set active-c5 count turtles with [cluster = 5 and is-active? = true]
end

to update-plot
  set-current-plot "AdoptionChart"
  plot count turtles with [adopted? = true]
end

to export-results
  let total-adopters count turtles with [adopted? = true]
  let adoption-rate precision (total-adopters / count turtles * 100) 1
  let avg-links precision (sum [count link-neighbors] of turtles / count turtles) 2
  let satisfied-adopters count turtles with [adopted? = true and satisfied? = true]
  print (word empfehlung "," informationskampagnen "," funktionserweiterung ","
             geraetekompatibilitaet "," total-adopters "," adopter-c1 "," adopter-c2 ","
             adopter-c3 "," adopter-c4 "," adopter-c5 "," ticks "," adoption-rate ","
             avg-links "," satisfied-adopters ","
             active-c1 "," active-c2 "," active-c3 "," active-c4 "," active-c5)
end

to clear-values
  set empfehlung 0
  set informationskampagnen 0
  set funktionserweiterung 0
  set geraetekompatibilitaet 0
end
@#$#@#$#@
GRAPHICS-WINDOW
302
10
628
337
-1
-1
9.64
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30

INPUTBOX
8
29
59
89
sharec1
2.5
1
0
Number

TEXTBOX
10
10
65
28
Cluster 1
11
3
1

INPUTBOX
7
115
59
175
sharec2
13.5
1
0
Number

TEXTBOX
9
96
59
115
Cluster 2
11
3
1

TEXTBOX
9
181
159
199
Cluster 3
11
3
1

INPUTBOX
6
199
59
259
sharec3
34
1
0
Number

TEXTBOX
10
265
160
283
Cluster 4
11
3
1

INPUTBOX
6
281
58
341
sharec4
34
1
0
Number

INPUTBOX
7
365
61
425
sharec5
16
1
0
Number

TEXTBOX
9
346
159
364
Cluster 5
11
3
1

INPUTBOX
63
30
130
90
attitudec1
5.02
1
0
Number

INPUTBOX
62
115
131
175
attitudec2
4.6
1
0
Number

INPUTBOX
62
200
129
260
attitudec3
4
1
0
Number

INPUTBOX
61
281
128
341
attitudec4
3.38
1
0
Number

INPUTBOX
63
366
128
426
attitudec5
2.92
1
0
Number

INPUTBOX
131
30
207
90
sub.normc1
4.75
1
0
Number

INPUTBOX
132
115
208
175
sub.normc2
3.84
1
0
Number

INPUTBOX
130
200
207
260
sub.normc3
3.33
1
0
Number

INPUTBOX
130
281
210
341
sub.normc4
3.12
1
0
Number

INPUTBOX
130
366
210
426
sub.normc5
1.59
1
0
Number

INPUTBOX
209
30
293
90
beh.controlc1
6.25
1
0
Number

INPUTBOX
209
115
294
175
beh.controlc2
5.34
1
0
Number

INPUTBOX
209
200
294
260
beh.controlc3
4.17
1
0
Number

INPUTBOX
210
281
294
341
beh.controlc4
3.85
1
0
Number

INPUTBOX
211
366
294
426
beh.controlc5
3.27
1
0
Number

TEXTBOX
971
286
1108
304
Agentenumwelt
11
3
1

SLIDER
969
306
1111
339
Empfehlung
empfehlung
0
1
0
0.05
1
NIL
HORIZONTAL

SLIDER
968
346
1113
379
Informationskampagnen
informationskampagnen
0
1
0
0.05
1
NIL
HORIZONTAL

SLIDER
968
384
1112
417
Funktionserweiterung
funktionserweiterung
0
1
0
0.05
1
NIL
HORIZONTAL


BUTTON
161
431
224
488
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
88
432
151
488
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
432
84
488
Clear-all
clear-values
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
968
14
1118
32
Modelleigenschaften
11
0
1

SLIDER
965
35
1134
68
num-agents
num-agents
0
500
315
1
1
NIL
HORIZONTAL



MONITOR
304
365
392
410
Adopter C1
count turtles with [cluster = 1 and adopted? = true]
17
1
11

MONITOR
304
415
393
460
Non-Adopter C1
count turtles with [cluster = 1 and adopted? = false]
17
1
11

MONITOR
401
365
482
410
AdopterC2
count turtles with [cluster = 2 and adopted? = true]
17
1
11

MONITOR
401
416
483
461
Non-AdopterC2
count turtles with [cluster = 2 and adopted? = false]
17
1
11

MONITOR
491
364
563
409
AdopterC3
count turtles with [cluster = 3 and adopted? = true]
17
1
11

MONITOR
490
416
564
461
Non-AdopterC3
count turtles with [cluster = 3 and adopted? = false]
17
1
11

MONITOR
570
364
642
409
AdopterC4
count turtles with [cluster = 4 and adopted? = true]
17
1
11

MONITOR
570
416
644
461
Non-AdopterC4
count turtles with [cluster = 4 and adopted? = false]
17
1
11

MONITOR
651
415
723
460
Non-AdopterC5
count turtles with [cluster = 5 and adopted? = false]
17
1
11

MONITOR
650
364
722
409
AdopterC5
count turtles with [cluster = 5 and adopted? = true]
17
1
11

SLIDER
964
146
1136
179
weight_Attitude
weight_attitude
0
1
0
0.05
1
NIL
HORIZONTAL

SLIDER
964
182
1136
215
weight_Sub-Norm
weight_sub-norm
0
1
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
964
217
1136
250
weight_behControl
weight_behcontrol
0
1
0.05
0.05
1
NIL
HORIZONTAL

PLOT
647
15
950
335
AdoptionChart
NIL
NIL
0
100
0
320
true
false
"" ""
PENS
"default" 1 0 -7500403 true "" ""

SLIDER
968
421
1110
454
geraetekompatibilitaet
geraetekompatibilitaet
0
1
0
0.05
1
NIL
HORIZONTAL

BUTTON
750
425
870
485
Export
export-results
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1
@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
