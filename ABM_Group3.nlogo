globals [ month
]
breed [ municipalities municpality ]
breed [ olds old ]
breed [ singles single ]
breed [ couples couple ]
breed [ families family ]
breed [ rec_companies rec_company ]

municipalities-own [ Budget
]
olds-own [ acceptance_rate_incentives                                                 ; acceptance_rate_incentives describes how well households react to incentives (cannot be influenced by incentives)
  perception_recycling                                                                ; describes how important recycling is perceived by the household  (can be influenced by incentives)
  knowledge_recycling                                                                 ; describes to what extend households are educated on how to recycle (can be influenced by incentives)
  recycling_rate                                                                      ; the recycling_rate is an equation derived from perception and knowledge
  presorted                                                                           ; recycling rate * pre factor (== decide how much recplastic is in waste) * waste ;; define how much potential recyclable plastic is in waste
  potential
  unsorted
  waste_base
  waste
]
singles-own [ acceptance_rate_incentives
  perception_recycling
  knowledge_recycling
  recycling_rate
  presorted
  potential
  unsorted
  waste_base
  waste
]
couples-own [ acceptance_rate_incentives
  perception_recycling
  knowledge_recycling
  recycling_rate
  presorted
  potential
  unsorted
  waste_base
  waste
]
families-own [ acceptance_rate_incentives
  perception_recycling
  knowledge_recycling
  recycling_rate
  presorted
  potential
  unsorted
  waste_base
  waste
]
rec_companies-own [ postsorting_presorted
  recycling_process_presorted
  postsorting_unsorted
  recycling_process_unsorted
  technology_unsorted
  technology_presorted
  presorted
  unsorted
  recycling_rate
  input
  capacity
  contract
  contract_capacity
  average_technology
  presorting_base
  unsorting_base
  waste
]

to setup
  clear-all
  setup_patches
  create-municipalities 1 [
    set color pink
    set size 3
    set shape "mun"
    set Budget (number_old + number_single + number_family + number_couple ) * 100
  ]
  setup-rec_companies
  create-olds number_old [
    set color blue
    set size 1
    set shape "elderly"
    set knowledge_recycling Knowledge_olds                                                                                                                              ; I think it is better if we split up the knowledge and perception to random numbers for all the elderlies to random values between x and y
    set perception_recycling Perception_olds
    set waste_base 36
    set acceptance_rate_incentives Acceptance_rate_Incentives_olds / 100
    move-to one-of patches with [ pcolor = grey]
  ]
    create-singles number_single [
    set color green
    set size 1
    set shape "person"
    set knowledge_recycling Knowledge_singles
    set perception_recycling Perception_singles
    set waste_base 38
    set acceptance_rate_incentives Acceptance_rate_Incentives_singles / 100
    move-to one-of patches with [ pcolor = grey]
  ]
    create-couples number_couple [
    set color yellow
    set size 1
    set shape "couple"                                                                                                                                   ; 40 is base waste while 1.4 is the factor for couples (hard coded we should change that to a adjustable variable maybe, incentives could lead to a reduction of the factor in general?)
    set knowledge_recycling Knowledge_couples
    set perception_recycling Perception_couples
    set waste_base 42
    set acceptance_rate_incentives Acceptance_rate_Incentives_couples / 100
    move-to one-of patches with [ pcolor = grey]
  ]
    create-families number_family [
    set color cyan
    set size 1
    set shape "family"
    set knowledge_recycling Knowledge_families
    set perception_recycling Perception_families
    set waste_base 44
    set acceptance_rate_incentives Acceptance_rate_Incentives_families / 100
    move-to one-of patches with [ pcolor = grey]
  ]



  set month 0

  reset-ticks
end
to setup-rec_companies
  ask n-of number_rec_companies ( patches with [pcolor = blue ]) [sprout-rec_companies 1]
    ask rec_companies[
    set size 3
    set shape "rec"
    let bridge_setup_rec_companies (number_old + number_single + number_couple + number_family) * 42  / number_rec_companies
    set capacity one-of (range bridge_setup_rec_companies (bridge_setup_rec_companies * 1.2))
    set contract 1 / number_rec_companies
    set presorting_base one-of (range 70 75)
    set unsorting_base one-of (range 45 50)
  ]
  ask rec_company 1 [set color red]
  if number_rec_companies >= 2 [ ask rec_company 2 [set color violet]]
  if number_rec_companies >= 3 [ ask rec_company 3 [set color yellow]]
  if number_rec_companies = 4 [ ask rec_company 4 [ set color black]]
end
to setup_patches
  ask patches [
    if number_rec_companies = 1 [
      if pxcor = -15 and pycor = 18 [ set pcolor blue]
  ]
    if number_rec_companies = 2 [
      if pxcor = -15 and pycor = 18 [ set pcolor blue]
      if pxcor = 15 and pycor = -18 [ set pcolor blue]
  ]
    if number_rec_companies = 3 [
      if pxcor = -15 and pycor = 18 [ set pcolor blue]
      if pxcor = 15 and pycor = -18 [ set pcolor blue]
      if pxcor = 15 and pycor = 18 [ set pcolor blue]
  ]
    if number_rec_companies = 4 [
      if pxcor = -15 and pycor = 18 [ set pcolor blue]
      if pxcor = 15 and pycor = -18 [ set pcolor blue]
      if pxcor = 15 and pycor = 18 [ set pcolor blue]
      if pxcor = -15 and pycor = -18 [ set pcolor blue]
  ]]
  ask patches with [ pycor < 17 and pxcor > -14 and pxcor < 14 and pycor > -17] [ set pcolor grey]
   ask patches with [ pcolor = black ] [
    set pcolor 54 + random 2
  ]
end

to go                                                                                                                           ; sets the time limit of the model to 2 years
  ;;General Functions
  if month >= 240 [ stop ]
  count_months

  ;;Housholds function
  waste-equation
  recycling_rate-equation
  recycled_plastics-equation
  potential-equation
  make_stupid
  unsorted-equation



  ;;Municipailty functions
  if month mod 12 = 0 [incentivice]
  if Visualization_Options = "Best_Performance" [if month mod 36 = 1  [visualize]]
  if Visualization_Options = "Realistic" [if month mod 36 = 1  [visualize_v2]]

  ;;Recycling companies Functions
  if Improve_technology_Options = "contract_size" [
    if month mod 12 = 0 [improve_technology_v1]]
  if Improve_technology_Options = "utilization" [
    if month mod 12 = 0 [improve_technology_v2]]
  rec_companies-equation
  rec_companies_recycling_rate-equation
  if month mod 36 = 0 [reset_contract]
  if month mod 36 = 0 [contract-equation]
  if month < 12 [fix_utilisation]
  tick
end

to count_months ; counter of months to count time
  set month month + 1
end

to waste-equation ; waste equation given depending on time
  ask (turtle-set singles olds families couples ) [
    set waste waste_base - 0.04 * month - exp(-0.01 * month) * sin( 0.3 * month)
  ]
end

to incentivice ; Municipalty Incentivice housholds with 2 options: General incentivice all households and specific incentivice only one houshold
  let tickrange one-of (range 1 99)                                                                                                                         ; generate random number between 1 and 99
  if tickrange >= Specified_Investment [                                                                                                                    ;specified_investment is a ratio of specified and general incentives, if the random tickrnage value is larger or equal to the specific_investment value a general inventive is chosen
    let incentive_general one-of (range 1 4)
    ask municipalities [ if budget > (number_old + number_single + number_family + number_couple ) * 3 [
    ask (turtle-set olds singles families couples) [
        if perception_recycling < 100 [
          set perception_recycling perception_recycling + incentive_general * acceptance_rate_incentives                                                                    ; the perception_recycling factor of one of the agentsets is increased by a random value between 1 and 4
        if knowledge_recycling < 100 [
          set knowledge_recycling knowledge_recycling + incentive_general * acceptance_rate_incentives                                                                      ; the knowledge_recycling factor of one of the agentsets is increased by a random value between 1 and 4
  ]]]
      set budget budget - (number_old + number_single + number_family + number_couple ) * 3]]]

  if tickrange <= Specified_Investment [                                                                                                                    ;specified_investment is a ratio of specified and general incentives, if the random tickrange value is smaller or equal to the specific_investment value a specific inventive is chosen which means just the agentset with the lowest recycling rate will be targeted for incentives
    let incentive_individual one-of (range 5 15)
    ask municipalities [ if budget > count (turtle-set olds singles families couples) with-max [ potential ] * 25 [
    ask (turtle-set olds singles families couples) with-max [ potential ] [
        if perception_recycling < 100 [
            set perception_recycling perception_recycling + incentive_individual * acceptance_rate_incentives
        if knowledge_recycling < 100 [
            set knowledge_recycling knowledge_recycling + incentive_individual * acceptance_rate_incentives
  ]]]
  ask (turtle-set singles olds families couples ) [
    if perception_recycling > 100 [set perception_recycling 100]
    if knowledge_recycling > 100 [set knowledge_recycling 100 ]
  ]
      set budget budget - count (turtle-set olds singles families couples) with-max [ potential ] * 25]]]
end

to make_stupid
  ask (turtle-set singles olds families couples) [
    set perception_recycling perception_recycling - 0.1
  ]
end

to recycling_rate-equation ; calculate the recycling rate of housholds with a weightening of 50/50 for knowledge_recycle and perception_recycle
  ask (turtle-set singles olds families couples) [
   set recycling_rate 0.5 * ( perception_recycling + knowledge_recycling )
  ]
end

to recycled_plastics-equation ; calculate presorted based on potential recycable plastic multiplied with recycling rate of turtles
   ask (turtle-set singles olds families couples ) [
   set presorted recycling_rate / 100 * waste * Amount_recycable_plastic / 100                                                                              ; Amount_recycable_plastic is the percentage of the potential recyclable plastic inside of the waste in general
  ]
end

to potential-equation ; This equation defines the potential of of each breed in ever tick | Potential = possible waste left to recycle in waste per breed
  ask olds [
    set potential number_old * ( (Amount_recycable_plastic / 100) * waste - presorted )
    ]
  ask singles [
    set potential number_single * ( (Amount_recycable_plastic / 100) * waste - presorted )
    ]
  ask families [
    set potential number_family * ( (Amount_recycable_plastic / 100) * waste - presorted )
    ]
  ask couples [
    set potential number_couple * ( (Amount_recycable_plastic / 100) * waste - presorted )
    ]
end

to unsorted-equation ; Calulate the unsorted waste of households through subtracting the presorted waste from the whole waste
  ask (turtle-set singles olds families couples ) [
    set unsorted waste - presorted
  ]
end

to rec_companies-equation ; simulate the recycling facilities and return average technology
  let sumofpresorted sum [ presorted ] of (turtle-set singles olds families couples )
  let recycling_process_presorted_random one-of (range 70 85)
  ask rec_companies [
    if month mod 36 = 0 [
     set average_technology average_technology / 36
  ]]
  ask rec_companies [
    set presorted sumofpresorted * contract
    set technology_presorted presorting_base + one-of (range -5 5)
    if technology_presorted > 100 [ set technology_presorted 100 ]
    set postsorting_presorted technology_presorted / 100 * presorted
    set recycling_process_presorted recycling_process_presorted_random / 100 * postsorting_presorted
  ]
  let sumofunsorted sum [ unsorted ] of (turtle-set singles olds families couples )
  ;restlichen % des plastics im waste berechnen
  let sumofwaste sum [ waste ] of (turtle-set singles olds families couples )
  let plastic_in_unsorted ((Amount_recycable_plastic / 100 * sumofwaste - sumofpresorted) / (sumofwaste - sumofpresorted))
  ;
  let recycling_process_unsorted_random one-of (range 55 70)
  ask rec_companies [
    set unsorted sumofunsorted * contract
    set technology_unsorted unsorting_base + one-of (range -10 10)
    if technology_unsorted > 100 [set technology_unsorted 100]
    set postsorting_unsorted technology_unsorted / 100 * unsorted * plastic_in_unsorted
    set recycling_process_unsorted recycling_process_unsorted_random / 100 * postsorting_unsorted
    ]
  ask rec_companies with [presorted != 0 ] [
    set average_technology average_technology + (presorted / (presorted + unsorted)) * technology_presorted / 100 + (unsorted / (presorted + unsorted)) * technology_unsorted / 100  ;; replace 0,5 with procent of processed type of waste
  ]

end

to rec_companies_recycling_rate-equation ; calculate the recycling rate of each recycling company and determine the variable input = unsorted waste
  let sumofwaste sum [ waste ] of (turtle-set singles olds families couples )
  let sumofpresorted sum [ presorted ] of (turtle-set singles olds families couples )
  ask rec_companies [
    if (presorted + unsorted) = 0 [
      set recycling_rate 0
    ]
    if (presorted + unsorted) != 0 [
    set recycling_rate (recycling_process_unsorted + recycling_process_presorted) / (presorted + unsorted)
    ]
  ]
  ask rec_companies [ if recycling_rate = 0 [die]]
 ask rec_companies [
   set input sumofwaste - sumofpresorted
  ]
end

to contract-equation
  let sumofwaste sum [waste] of (turtle-set singles olds families couples )
  let sumofcontract_capacity sum [contract_capacity] of rec_companies
  while [sumofwaste > sumofcontract_capacity] [
    let companies_list rec_companies with [contract_capacity = 0]
    ;print companies_list
    ask companies_list with-max[average_technology] [
        if capacity <= ( sumofwaste - sumofcontract_capacity ) [
          set contract_capacity capacity
          set contract contract_capacity / sumofwaste
        ]
        if capacity > ( sumofwaste - sumofcontract_capacity ) [
          set contract_capacity ( sumofwaste - sumofcontract_capacity )
          set contract contract_capacity / sumofwaste
        ]
  ]
  set sumofcontract_capacity sum [contract_capacity] of rec_companies]
  ask rec_companies [
    set waste sumofwaste * contract
  ]
end

to reset_contract ;reset the assigned capacity of ech recycling company
  ask rec_companies [
    set contract_capacity 0
    set contract 0
  ]
end

to improve_technology_v1
  ask rec_companies with-max [contract] [
      set capacity capacity * ( 1 + one-of (range 5 10) / 100)
      set presorting_base presorting_base - one-of (range 0 2)
      set unsorting_base unsorting_base - one-of (range 0 2)
  ]
  ask rec_companies with-min [contract] [
      set capacity capacity * ( 1 - one-of (range 0 5) / 100)
      set presorting_base presorting_base + one-of (range 2 4)
      set unsorting_base unsorting_base + one-of (range 2 4)
  ]
  ask rec_companies [
    set capacity capacity * ( 1 + one-of (range 0 3) / 100)
      set presorting_base presorting_base + one-of (range 0 2)
      set unsorting_base unsorting_base + one-of (range 0 2)
  ]
  ask rec_companies [ if presorting_base > 100 [set presorting_base 100]]
end

to improve_technology_v2
  ask rec_companies with-max [contract_capacity / capacity] [
      set capacity capacity * ( 1 + one-of (range 5 10) / 100)
      set presorting_base presorting_base - one-of (range 0 2)
      set unsorting_base unsorting_base - one-of (range 0 2)
  ]
  ask rec_companies with-min [contract_capacity / capacity] [
      set capacity capacity * ( 1 - one-of (range 0 5) / 100)
      set presorting_base presorting_base + one-of (range 2 4)
      set unsorting_base unsorting_base + one-of (range 2 4)
  ]
  ask rec_companies [
    set capacity capacity * ( 1 + one-of (range 0 3) / 100)
      set presorting_base presorting_base + one-of (range 0 2)
      set unsorting_base unsorting_base + one-of (range 0 2)
  ]
  ask rec_companies [ if presorting_base > 100 [set presorting_base 100]]
end

to fix_utilisation
  ask rec_companies [
    set contract_capacity presorted + unsorted]
end

to visualize ; Best performance
  ask patches with [pcolor = (red + 1) or pcolor = (violet + 1) or pcolor = (yellow + 2) or pcolor = (black + 3)] [ set pcolor grey]
  let nenner count patches with [pcolor = grey]
  let area1 0
  let area2 0
  let area3 0
  let area4 0

  if number_rec_companies = 1 [
    set area1 round ([contract] of rec_company 1 * nenner)
    ask n-of area1 patches with [pcolor = grey] [set pcolor red + 1]
  ]
  if number_rec_companies = 2 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    while [area1 + area2 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]]
    ask n-of area1 patches with [pcolor = grey] [set pcolor red + 1]
    ask n-of area2 patches with [pcolor = grey] [set pcolor violet + 1 ]
  ]

  if number_rec_companies = 3 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    if rec_company 3 != nobody [set area3 round ([contract] of rec_company 3 * nenner)]
    while [area1 + area2 + area3 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]
      if area3 != 0 [set area3 area3 - 1]]
    ask n-of area1 patches with [pcolor = grey] [set pcolor red + 1]
    ask n-of area2 patches with [pcolor = grey] [set pcolor violet + 1 ]
    ask n-of area3 patches with [pcolor = grey] [set pcolor yellow + 2]
  ]
  if number_rec_companies = 4 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    if rec_company 3 != nobody [set area3 round ([contract] of rec_company 3 * nenner)]
    if rec_company 4 != nobody [set area4 round ([contract] of rec_company 4 * nenner)]
    while [area1 + area2 + area3 + area4 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]
      if area3 != 0 [set area3 area3 - 1]
      if area4 != 0 [set area4 area4 - 1]]
    ask n-of area1 patches with [pcolor = grey] [set pcolor red + 1]
    ask n-of area2 patches with [pcolor = grey] [set pcolor violet + 1 ]
    ask n-of area3 patches with [pcolor = grey] [set pcolor yellow + 2]
    ask n-of area4 patches with [pcolor = grey] [set pcolor black + 3]
  ]
end

to visualize_v2 ; The most realistic one
  ask patches with [pcolor = (red + 1) or pcolor = (violet + 1) or pcolor = (yellow + 2) or pcolor = (black + 3)] [ set pcolor grey]
  let nenner count patches with [pcolor = grey]
  let area1 0
  let area2 0
  let area3 0
  let area4 0
  let redcheck count patches with [pcolor = red + 1]
  let violetcheck count patches with [pcolor = violet + 1]
  let yellowcheck count patches with [pcolor = yellow + 2]
  let blackcheck count patches with [pcolor = black + 3]

  if number_rec_companies = 1 [
    set area1 round ([contract] of rec_company 1 * nenner)
    ask n-of area1 patches with [pcolor = grey] [set pcolor red + 1]
  ]
  if number_rec_companies = 2 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    while [area1 + area2 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]]
    while [redcheck != area1] [
      let redlist patches with [pcolor = grey]
      ask n-of 1 redlist with-min [distance rec_company 1] [ set pcolor red + 1]
      set redlist patches with [pcolor = grey]
      set redcheck count patches with [pcolor = red + 1]
  ]
    while [violetcheck != area2] [
      let violetlist patches with [pcolor = grey]
      ask n-of 1 violetlist with-min [distance rec_company 2] [ set pcolor violet + 1]
      set violetlist patches with [pcolor = grey]
      set violetcheck count patches with [pcolor = violet + 1]
]]

  if number_rec_companies = 3 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    if rec_company 3 != nobody [set area3 round ([contract] of rec_company 3 * nenner)]
    while [area1 + area2 + area3 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]
      if area3 != 0 [set area3 area3 - 1]]
  while [redcheck != area1] [
    let redlist patches with [pcolor = grey]
      ask n-of 1 redlist with-min [distance rec_company 1] [ set pcolor red + 1]
    set redlist patches with [pcolor = grey]
    set redcheck count patches with [pcolor = red + 1]
  ]
  while [violetcheck != area2] [
    let violetlist patches with [pcolor = grey]
    ask n-of 1 violetlist with-min [distance rec_company 2] [ set pcolor violet + 1]
    set violetlist patches with [pcolor = grey]
    set violetcheck count patches with [pcolor = violet + 1]
  ]
    while [yellowcheck != area3] [
    let yellowlist patches with [pcolor = grey]
    ask n-of 1 yellowlist with-min [distance rec_company 3] [ set pcolor yellow + 2]
    set yellowlist patches with [pcolor = grey]
    set yellowcheck count patches with [pcolor = yellow + 2]
  ]]

  if number_rec_companies = 4 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    if rec_company 3 != nobody [set area3 round ([contract] of rec_company 3 * nenner)]
    if rec_company 4 != nobody [set area4 round ([contract] of rec_company 4 * nenner)]
    while [area1 + area2 + area3 + area4 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]
      if area3 != 0 [set area3 area3 - 1]
      if area4 != 0 [set area4 area4 - 1]]
    while [redcheck != area1] [
      let redlist patches with [pcolor = grey]
      ask n-of 1 redlist with-min [distance rec_company 1] [ set pcolor red + 1]
        set redlist patches with [pcolor = grey]
        set redcheck count patches with [pcolor = red + 1]
  ]
      while [violetcheck != area2] [
        let violetlist patches with [pcolor = grey]
        ask n-of 1 violetlist with-min [distance rec_company 2] [ set pcolor violet + 1]
        set violetlist patches with [pcolor = grey]
        set violetcheck count patches with [pcolor = violet + 1]
  ]
      while [yellowcheck != area3] [
        let yellowlist patches with [pcolor = grey]
        ask n-of 1 yellowlist with-min [distance rec_company 3] [ set pcolor yellow + 2]
        set yellowlist patches with [pcolor = grey]
        set yellowcheck count patches with [pcolor = yellow + 2]
  ]
          while [blackcheck != area4] [
        let blacklist patches with [pcolor = grey]
        ask n-of 1 blacklist with-min [distance rec_company 4] [ set pcolor black + 3]
        set blacklist patches with [pcolor = grey]
        set blackcheck count patches with [pcolor = black + 3]
  ]]
end

to visualize_v3 ; looks like a circle
  ask patches with [pcolor = (red + 1) or pcolor = (violet + 1) or pcolor = (yellow + 2) or pcolor = (black + 3)] [ set pcolor grey]
  let nenner count patches with [pcolor = grey]
  let area1 0
  let area2 0
  let area3 0
  let area4 0
  let redcheck count patches with [pcolor = red + 1]
  let violetcheck count patches with [pcolor = violet + 1]
  let yellowcheck count patches with [pcolor = yellow + 2]

  if number_rec_companies = 1 [
    set area1 round ([contract] of rec_company 1 * nenner)
    ask n-of area1 patches with [pcolor = grey] [set pcolor red + 1]
  ]
  if number_rec_companies = 2 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    while [area1 + area2 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]]
  while [redcheck != area1] [
    let redlist patches with [pcolor = grey]
    ask n-of 1 redlist with-min [distance turtle 0] [ set pcolor red + 1
    show distance rec_company 1]
    set redlist patches with [pcolor = grey]
    set redcheck count patches with [pcolor = red + 1]
  ]
  while [violetcheck != area2] [
    let violetlist patches with [pcolor = grey]
    ask n-of 1 violetlist with-min [distance turtle 0] [ set pcolor violet + 1]
    set violetlist patches with [pcolor = grey]
    set violetcheck count patches with [pcolor = violet + 1]
  ]]

  if number_rec_companies = 3 [
    if rec_company 1 != nobody [ set area1 round ([contract] of rec_company 1 * nenner)]
    if rec_company 2 != nobody [set area2 round ([contract] of rec_company 2 * nenner)]
    if rec_company 3 != nobody [set area3 round ([contract] of rec_company 3 * nenner)]
    while [area1 + area2 + area3 > nenner] [
      if area1 != 0 [set area1 area1 - 1]
      if area2 != 0 [set area2 area2 - 1]
      if area3 != 0 [set area3 area3 - 1]]
  while [redcheck != area1] [
    let redlist patches with [pcolor = grey]
      ask n-of 1 redlist with-min [distance turtle 0] [ set pcolor red + 1]
    set redlist patches with [pcolor = grey]
    set redcheck count patches with [pcolor = red + 1]
  ]
  while [violetcheck != area2] [
    let violetlist patches with [pcolor = grey]
    ask n-of 1 violetlist with-min [distance turtle 0] [ set pcolor violet + 1]
    set violetlist patches with [pcolor = grey]
    set violetcheck count patches with [pcolor = violet + 1]
  ]
  while [yellowcheck != area3] [
    let yellowlist patches with [pcolor = grey]
        ask n-of 1 yellowlist with-min [distance turtle 0] [ set pcolor yellow + 2]
    set yellowlist patches with [pcolor = grey]
    set yellowcheck count patches with [pcolor = yellow + 2]
      ]]
end
@#$#@#$#@
GRAPHICS-WINDOW
284
70
721
586
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-19
19
1
1
1
ticks
30.0

BUTTON
34
17
97
50
NIL
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

INPUTBOX
8
112
136
172
number_old
50.0
1
0
Number

INPUTBOX
148
112
273
172
number_single
50.0
1
0
Number

INPUTBOX
147
183
272
243
number_family
50.0
1
0
Number

INPUTBOX
9
183
136
243
number_couple
50.0
1
0
Number

SLIDER
11
396
273
429
number_rec_companies
number_rec_companies
1
4
4.0
1
1
NIL
HORIZONTAL

BUTTON
109
17
173
51
go once
go
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
184
17
247
50
go
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

SLIDER
9
250
272
283
Specified_Investment
Specified_Investment
0
100
50.0
10
1
NIL
HORIZONTAL

PLOT
1134
72
1764
589
Plastic Sorting Rates of Housholds and Recycling Rate of City
Ticks [Month]
Rates [%]
0.0
240.0
0.0
20.0
true
true
"" ""
PENS
"Singles" 1.0 0 -10899396 true "" "plot mean [recycling_rate] of singles"
"Families" 1.0 0 -11221820 true "" "plot mean [recycling_rate] of families"
"Couples" 1.0 0 -1184463 true "" "plot mean [recycling_rate] of couples"
"Olds" 1.0 0 -13345367 true "" "plot mean [recycling_rate] of olds "
"Recycling Rate City Regarding Waste" 1.0 0 -9276814 true "" "if month > 1 [plot mean [recycling_rate] of rec_companies with [recycling_rate != 0] * 100 ]"
"Recycling Rate City Regarding Plastics" 1.0 0 -16777216 true "" "if month > 1 [plot (sum [recycling_process_presorted + recycling_process_unsorted] of rec_companies) / (sum [waste] of (turtle-set olds singles families couples) * Amount_recycable_plastic / 100) * 100]"

PLOT
732
72
1124
587
Waste of City
Ticks [Month]
Amount of Good [KG]
0.0
241.0
0.0
10.0
true
true
"" ""
PENS
"Waste of City" 1.0 0 -16777216 true "" "plot  sum [waste] of (turtle-set olds singles families couples)"
"Plastic of City" 1.0 1 -9276814 true "" "plot  sum [waste] of (turtle-set olds singles families couples) * Amount_recycable_plastic / 100"
"Recycled Plastic of City" 1.0 1 -14333415 true "" "plot  sum [recycling_process_presorted + recycling_process_unsorted] of rec_companies"

SLIDER
10
291
272
324
Amount_recycable_plastic
Amount_recycable_plastic
0
100
30.0
10
1
%
HORIZONTAL

PLOT
0
822
702
1124
Highest Line Gets the INDIVIDUAL Incentive
Ticks [Month]
Absolute Plastic that could be recycled [Kg]
0.0
240.0
0.0
10.0
true
true
"" ""
PENS
"olds" 1.0 0 -13345367 true "" "plot mean [waste] of olds * count olds * Amount_recycable_plastic / 100 -  mean [presorted] of olds * count olds"
"singles" 1.0 0 -10899396 true "" "plot mean [waste] of singles * count singles * Amount_recycable_plastic / 100 -  mean [presorted] of singles * count singles"
"families" 1.0 0 -11221820 true "" "plot mean [waste] of families * count families * Amount_recycable_plastic / 100 -  mean [presorted] of families * count families"
"couples" 1.0 0 -1184463 true "" "plot mean [waste] of couples * count couples * Amount_recycable_plastic / 100 -  mean [presorted] of couples * count couples"

SLIDER
105
643
331
676
Acceptance_rate_Incentives_olds
Acceptance_rate_Incentives_olds
0
100
95.0
10
1
NIL
HORIZONTAL

SLIDER
105
683
333
716
Acceptance_rate_Incentives_singles
Acceptance_rate_Incentives_singles
0
100
40.0
10
1
NIL
HORIZONTAL

SLIDER
105
726
333
759
Acceptance_rate_Incentives_families
Acceptance_rate_Incentives_families
0
100
80.0
10
1
NIL
HORIZONTAL

SLIDER
105
766
336
799
Acceptance_rate_Incentives_couples
Acceptance_rate_Incentives_couples
0
100
70.0
10
1
NIL
HORIZONTAL

PLOT
1772
75
2154
593
Recycling Companies Process with Presorted Waste
Ticks [Month]
Plastics [Kg]
0.0
240.0
0.0
10.0
true
true
"" ""
PENS
"Plastic input" 1.0 0 -4539718 true "" "plot mean [presorted] of rec_companies"
"Postsorting Output" 1.0 0 -9276814 true "" "plot mean [postsorting_presorted] of rec_companies"
"Recycling Outpput" 1.0 0 -16777216 true "" "plot mean [recycling_process_presorted] of rec_companies"

PLOT
1417
600
1737
857
Capacity of Recycling Companies
Ticks [Month]
Capacity [Kg]
0.0
240.0
0.0
10.0
true
true
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "ask rec_companies [\n  create-temporary-plot-pen (word who)\n  set-plot-pen-color color\n  plotxy ticks (capacity)\n  ]"

PLOT
734
600
1079
857
Capacity Utilisation [%] After Each Contract
Ticks [Months]
Capacity Utilisation [%]
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ask rec_companies [\n if month mod 36 = 0 or month = 1[\n  create-temporary-plot-pen (word who)\n  set-plot-pen-color color\n  plotxy ticks (contract_capacity / capacity * 100)\n  ]]"

CHOOSER
11
438
272
483
Improve_Technology_Options
Improve_Technology_Options
"utilization" "contract_size"
0

MONITOR
433
15
568
60
Budget of municipality
mean [budget] of municipalities
17
1
11

MONITOR
930
15
1124
60
Recycling Rate Regarding Plastics
(sum [recycling_process_presorted + recycling_process_unsorted] of rec_companies) / (sum [waste] of (turtle-set olds singles families couples) * Amount_recycable_plastic / 100) * 100
1
1
11

TEXTBOX
14
357
264
386
Setup Recycling Companies
16
0.0
1

TEXTBOX
10
77
234
112
Setup City
16
0.0
1

TEXTBOX
5
613
264
653
Setup Households in Detail ↓
16
0.0
1

MONITOR
733
16
919
61
Recycling Rate Regarding Waste
mean [recycling_rate] of rec_companies with [recycling_rate != 0] * 100
1
1
11

SLIDER
346
643
519
676
Perception_olds
Perception_olds
0
100
10.0
10
1
NIL
HORIZONTAL

SLIDER
529
643
702
676
Knowledge_olds
Knowledge_olds
0
100
20.0
10
1
NIL
HORIZONTAL

SLIDER
345
685
518
718
Perception_singles
Perception_singles
0
100
50.0
10
1
NIL
HORIZONTAL

SLIDER
529
685
702
718
Knowledge_singles
Knowledge_singles
0
100
30.0
10
1
NIL
HORIZONTAL

SLIDER
343
726
516
759
Perception_families
Perception_families
0
100
50.0
10
1
NIL
HORIZONTAL

SLIDER
530
726
703
759
Knowledge_families
Knowledge_families
0
100
60.0
10
1
NIL
HORIZONTAL

SLIDER
530
766
703
799
Knowledge_couples
Knowledge_couples
0
100
60.0
10
1
NIL
HORIZONTAL

SLIDER
345
766
518
799
Perception_couples
Perception_couples
0
100
70.0
10
1
NIL
HORIZONTAL

TEXTBOX
10
654
75
674
Olds
16
0.0
1

TEXTBOX
10
691
81
711
Singles
16
0.0
1

TEXTBOX
8
733
72
753
Families
16
0.0
1

TEXTBOX
9
773
78
793
Couples
16
0.0
1

PLOT
735
865
1079
1127
Company Assignment to % of City 
Ticks [Month]
Contract Volume [% of City]
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ask rec_companies [\n if month mod 36 = 0 or month = 1[\n  create-temporary-plot-pen (word who)\n  set-plot-pen-color color\n  plotxy ticks (contract * 100)\n  ]]"

PLOT
1087
600
1411
857
Presorting Technology
Ticks [Month]
Success Rate for Presorted Waste [%]
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"Recycling Company:" 1.0 0 -1 true "" "  ask rec_companies [\n  create-temporary-plot-pen (word who)\n  set-plot-pen-color color\n  plotxy ticks (technology_presorted)\n  ]"

PLOT
2159
75
2507
595
Recycling Companies Process with Unsorted Waste
Ticks [Month]
Waste and Plastics [Kg]
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Unsorted Waste Input" 1.0 0 -3026479 true "" "plot mean [unsorted] of rec_companies"
"Postsorting Output" 1.0 0 -7500403 true "" "plot mean [postsorting_unsorted] of rec_companies"
"Recycling Output" 1.0 0 -16777216 true "" "plot mean [recycling_process_unsorted] of rec_companies"

PLOT
1087
865
1407
1127
Technology Unsorted
Ticks [Month]
Success Rate for Unsorted Waste [%]
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"default" 1.0 0 -16777216 true "" "  ask rec_companies [\n  create-temporary-plot-pen (word who)\n  set-plot-pen-color color\n  plotxy ticks (technology_unsorted)\n  ]"

CHOOSER
12
495
272
540
Visualization_Options
Visualization_Options
"Realistic" "Best_Performance"
1

@#$#@#$#@
Must have

Data analysis --> reflektieren Assumptions EInfluss. Komplett sein


Assumptions


Households have
-perception_rate: Describes how important recycling is to the household
-knowlege_recycle: Describes the knowledge about how to recycle
-acceptance_rate_incentives: Describes the acceptance of incentives and policies
-recycling_rate: Is the rate of how well the household seperates the trash

recycling_company
have:
*color --> property
*shape --> property
*technology --> ?
	*sorting_effeciency
	*recycling_efficency
	*capacity

Pesudocode:

Initialization:
	
	Create agents (households) and evenly distribute them random in knowledge space

	Create agent (municipality) in (0,0) of the knowledge space

	Create given amount of agents (recycling companies) and place them on a fixed spot

	Create classes for agent (households):
		old
		single
		couple
		family

	Households own:
		waste
		access to collection infrastructure
		perception for recycling
		knowledge of how to recycle
		acceptance rate for incentives

	Municipality own:
		Budget
		desity
		population distribution
















Pseudocode Muncicpality Incentivizing households


;;in to go function: stop incentivizing e.g. if knowledge_recycling >= 100
;; Include decide random as propability slider



if Budget of Municipality > 0:
	decide random: inventivize ALL-Agents (1) OR Incentivize SPECIFIC-Agent (2)

(1)    Budget - incentivizing costs x4
       set knowledge_recycling + random number between  e.g. 0 and 4
       set perception_recycling + random number between  e.g. 0 and 4
       set acceptance_rate_incentives + random number between  e.g. 0 and 4 ;; je öfter man incentivized wird desto eher werden die leute aufnahmefähiger ???

(2)    choose which agent has lowest recycling rate
       Budget - incentivizing costs x1
       set knowledge_recycling + random number between  e.g. 0 and 4
       set perception_recycling + random number between  e.g. 0 and 4
       set acceptance_rate_incentives + random number between  e.g. 0 and 4 ;; je öfter man incentivized wird desto eher werden die leute aufnahmefähiger ???
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

couple
false
0
Circle -7500403 true true 44 6 80
Polygon -7500403 true true 39 90 54 195 24 285 39 300 69 300 84 225 99 300 129 300 144 285 114 195 129 90
Rectangle -7500403 true true 62 77 107 92
Polygon -7500403 true true 129 88 160 152 141 183 99 103
Polygon -7500403 true true 40 91 -5 151 10 181 70 106
Polygon -7500403 true true 170 92 185 197 155 287 170 302 200 302 215 227 230 302 260 302 275 287 245 197 260 92
Polygon -7500403 true true 170 90 139 154 158 185 200 105
Rectangle -7500403 true true 195 78 240 93
Circle -7500403 true true 177 4 80
Polygon -7500403 true true 263 91 294 155 275 186 233 106

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

elderly
false
0
Circle -7500403 true true 104 6 80
Polygon -7500403 true true 99 90 114 195 84 285 99 300 129 300 144 225 159 300 189 300 204 285 174 195 189 90
Rectangle -7500403 true true 122 77 167 92
Polygon -7500403 true true 100 91 55 151 70 181 130 106
Polygon -7500403 true true 185 91 230 151 215 181 155 106
Rectangle -7500403 true true 210 150 225 285
Rectangle -7500403 true true 210 165 240 180
Rectangle -16777216 true false 210 270 225 285

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

family
false
0
Circle -7500403 true true 74 6 80
Polygon -7500403 true true 69 90 84 195 54 285 69 300 99 300 114 225 129 300 159 300 174 285 144 195 159 90
Rectangle -7500403 true true 92 77 137 92
Polygon -7500403 true true 70 91 25 151 40 181 100 106
Polygon -7500403 true true 155 91 200 151 185 181 125 106
Circle -7500403 true true 232 149 34
Polygon -7500403 true true 225 195 225 240 225 285 210 300 240 300 249 255 255 300 285 300 270 285 270 240 270 195
Rectangle -7500403 true true 242 180 255 197
Polygon -7500403 true true 225 195 195 165 195 180 225 210
Polygon -7500403 true true 270 195 300 225 300 240 270 210

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

hh
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

mun
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 104 6 80
Polygon -7500403 true true 99 90 114 195 84 285 99 300 129 300 144 225 159 300 189 300 204 285 174 195 189 90
Rectangle -7500403 true true 122 77 167 92
Polygon -7500403 true true 100 91 55 151 70 181 130 106
Polygon -7500403 true true 185 91 230 151 215 181 155 106

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

rec
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

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
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Sophian vorlage" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240"/>
    <metric>sum [recycling_rate * contract] of rec_companies</metric>
    <metric>(sum [recycling_process_presorted + recycling_process_unsorted] of rec_companies) / (sum [waste] of (turtle-set olds singles families couples) * Amount_recycable_plastic / 100) * 100</metric>
    <metric>sum [technology_presorted * contract] of rec_companies</metric>
    <metric>sum [technology_unsorted * contract] of rec_companies</metric>
    <metric>count rec_companies</metric>
    <metric>[recycling_rate] of olds</metric>
    <metric>[recycling_rate] of singles</metric>
    <metric>[recycling_rate] of couples</metric>
    <metric>[recycling_rate] of families</metric>
    <enumeratedValueSet variable="Amount_recycable_plastic">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_singles">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_old">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_family">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_olds">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_families">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_single">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_couple">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_couples">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_rec_companies">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Specified_Investment">
      <value value="0"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Improve_Technology_Options">
      <value value="&quot;contract_size&quot;"/>
      <value value="&quot;utilization&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Sophian part 1" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240"/>
    <metric>sum [recycling_rate * contract] of rec_companies</metric>
    <metric>(sum [recycling_process_presorted + recycling_process_unsorted] of rec_companies) / (sum [waste] of (turtle-set olds singles families couples) * Amount_recycable_plastic / 100) * 100</metric>
    <metric>sum [technology_presorted * contract] of rec_companies</metric>
    <metric>sum [technology_unsorted * contract] of rec_companies</metric>
    <metric>count rec_companies</metric>
    <enumeratedValueSet variable="Amount_recycable_plastic">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_singles">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_old">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_family">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_olds">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_families">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_single">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_couple">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_couples">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_rec_companies">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Specified_Investment">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Improve_Technology_Options">
      <value value="&quot;contract_size&quot;"/>
      <value value="&quot;utilization&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Sophian part 2" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240"/>
    <metric>sum [recycling_rate * contract] of rec_companies</metric>
    <metric>(sum [recycling_process_presorted + recycling_process_unsorted] of rec_companies) / (sum [waste] of (turtle-set olds singles families couples) * Amount_recycable_plastic / 100) * 100</metric>
    <metric>[recycling_rate] of olds</metric>
    <metric>[recycling_rate] of singles</metric>
    <metric>[recycling_rate] of couples</metric>
    <metric>[recycling_rate] of families</metric>
    <enumeratedValueSet variable="Amount_recycable_plastic">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_singles">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_old">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_family">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_olds">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_families">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_single">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_couple">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Acceptance_rate_Incentives_couples">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_rec_companies">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Specified_Investment">
      <value value="0"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Improve_Technology_Options">
      <value value="&quot;utilization&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@
