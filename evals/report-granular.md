# Eval Report — camping-v0.1.0.trailpack

Eval set: `camping-granular-100q.yaml` · 100 queries

Verdicts: ✓ pass · ◐ weak · ✗ fail


## Summary

- ✓ pass: **86** / 100 (86%)
- ◐ weak: **10** / 100
- ✗ fail: **4** / 100

### Per-domain

- `wildlife` — ✓ 34 · ◐ 1 · ✗ 0 / 35
- `plants` — ✓ 16 · ◐ 6 · ✗ 0 / 22
- `knots` — ✓ 17 · ◐ 0 · ✗ 0 / 17
- `first-aid` — ✓ 19 · ◐ 3 · ✗ 2 / 24
- `_other_` — ✓ 0 · ◐ 0 · ✗ 2 / 2

---

## ✓ [1/100] 'water hemlock root chambered'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Water hemlock identification* (hybrid=0.82, kw=1.00, vec=0.74) — `plants.poison-hemlock#2`
  > Smaller than poison hemlock (2–6 feet). Stems are hollow with chambered roots (cut a root open lengthwise — chambers are diagnostic). Leaves are pinnately divided. White flowers in umbrella clusters. Found in wet places: marshes, stream …

**2.** `plants` · *What to do* (hybrid=0.71, kw=0.52, vec=0.80) — `plants.water-hemlock#4`
  > If anyone is suspected of eating or chewing water hemlock, evacuate immediately to emergency medical care. Call Poison Control (1-800-222-1222 in the US). Do not induce vomiting unless directed. Bring a sample of the plant — root, stem, …

**3.** `plants` · *Identification* (hybrid=0.71, kw=0.83, vec=0.66) — `plants.water-hemlock#1`
  > 2–6 feet tall (smaller than poison hemlock). Hollow stems often streaked or splotched purple at the base. Leaves pinnately compound, sharply toothed, with veins ending in the NOTCHES between teeth rather than in the teeth themselves — a …

- _top result hit keywords: ['chambered', 'hollow']_

---

## ◐ [2/100] 'deadly plant near streams that looks like wild carrot'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Why it kills people* (hybrid=0.86, kw=1.00, vec=0.81) — `plants.water-hemlock#2`
  > Roots look and smell almost exactly like wild parsnip, wild carrot (Queen Anne's lace), or wild celery. Foragers digging "wild carrots" near streams have repeatedly died. The toxin works fast — symptoms within 15–60 minutes. By the time …

**2.** `plants` · *Why you can't trust ID by appearance alone* (hybrid=0.77, kw=0.68, vec=0.81) — `plants.poison-hemlock#4`
  > Both species look almost exactly like wild carrot, parsley, parsnip, fennel, anise, and several other common edible plants from a glance. Even experienced foragers misidentify carrot-family plants and die. The chambered roots of water he…

**3.** `plants` · *Avoiding it* (hybrid=0.75, kw=0.60, vec=0.81) — `plants.water-hemlock#5`
  > The simplest rule: do not eat any wild plant from the carrot family (Apiaceae) without expert in-person identification. The carrot family contains both edibles (carrot, parsnip, celery, fennel, anise, parsley, dill) and deadly species (w…

- _no expected topic keywords found in top result: ['water hemlock', 'cicuta', 'carrot family']_

---

## ✓ [3/100] 'death camas wild onion confusion'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *The general rule* (hybrid=0.92, kw=1.00, vec=0.89) — `plants.death-camas#5`
  > This pack will not identify any plant as safe to eat. The death camas / wild onion confusion has killed careful, informed people. Both grow in beautiful mountain meadows alongside abundant safer food. Do not eat any bulb without expert i…

**2.** `plants` · *The key identification difference* (hybrid=0.87, kw=0.89, vec=0.87) — `plants.death-camas#1`
  > **Wild onion has the unmistakable onion or garlic smell when crushed. Death camas does NOT.** Always crush a leaf and sniff before considering any onion-like bulb. No onion smell = do not eat. Death camas leaves are grass-like, V-shaped …

**3.** `plants` · *Why it kills foragers* (hybrid=0.83, kw=0.83, vec=0.83) — `plants.death-camas#0`
  > Death camas (Zigadenus, sometimes Toxicoscordion) looks similar to wild onions and edible camas lily — both used historically as food by Native peoples. It contains zygacine, a steroidal alkaloid that affects the heart and nerves. As lit…

- _top result hit keywords: ['death camas']_

---

## ✗ [4/100] 'is this wild onion or death camas'

> _Refusal — but the plant content should be available for awareness._

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *The general rule* (hybrid=0.91, kw=0.94, vec=0.90) — `plants.death-camas#5`
  > This pack will not identify any plant as safe to eat. The death camas / wild onion confusion has killed careful, informed people. Both grow in beautiful mountain meadows alongside abundant safer food. Do not eat any bulb without expert i…

**2.** `plants` · *The key identification difference* (hybrid=0.91, kw=1.00, vec=0.87) — `plants.death-camas#1`
  > **Wild onion has the unmistakable onion or garlic smell when crushed. Death camas does NOT.** Always crush a leaf and sniff before considering any onion-like bulb. No onion smell = do not eat. Death camas leaves are grass-like, V-shaped …

**3.** `plants` · *Why it kills foragers* (hybrid=0.88, kw=0.94, vec=0.85) — `plants.death-camas#0`
  > Death camas (Zigadenus, sometimes Toxicoscordion) looks similar to wild onions and edible camas lily — both used historically as food by Native peoples. It contains zygacine, a steroidal alkaloid that affects the heart and nerves. As lit…

- _intent: got 'general', expected 'plant_id_edibility'_

---

## ◐ [5/100] 'foxglove ate flower'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Avoiding it* (hybrid=0.88, kw=1.00, vec=0.82) — `plants.foxglove#5`
  > Don't plant foxglove if you have small children. Teach kids never to eat any garden flower. In the wild, admire the spectacular flower spikes from a distance and do not pick them — sap on hands can transfer to food. Many foragers who use…

**2.** `plants` · *Common confusions* (hybrid=0.87, kw=0.99, vec=0.81) — `plants.foxglove#3`
  > Foxglove leaves are sometimes mistaken for comfrey, especially before flowering. Comfrey leaves are also fuzzy and gray-green. Comfrey has been used in herbal medicine; people brewing "comfrey tea" from misidentified foxglove leaves have…

**3.** `plants` · *Pacific yew, oleander, foxglove, white snakeroot — known cardiac toxins* (hybrid=0.83, kw=0.92, vec=0.79) — `plants.dangerous-plants#6`
  > All cause severe cardiac symptoms if eaten. Foxglove (digitalis) is a common garden escapee. Oleander grows in the warm South and West. Never eat any unidentified flower or berry.

- _no expected topic keywords found in top result: ['digitalis', 'cardiac', 'evacuate']_

---

## ✓ [6/100] 'jimsonweed datura poisoning'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Recreational use is a major hazard* (hybrid=0.88, kw=1.00, vec=0.83) — `plants.datura#4`
  > Datura is sometimes sought out for hallucinogenic effects. Internet folklore suggests "safe doses" — none exist. The toxic concentration varies wildly between plants, parts of the same plant, and even season. Hospital-documented deaths a…

**2.** `plants` · *Why it kills* (hybrid=0.88, kw=1.00, vec=0.83) — `plants.datura#0`
  > Datura contains tropane alkaloids (atropine, scopolamine, hyoscyamine) that affect the nervous system and heart. People are poisoned three ways: eating berries or seeds (kids find them attractive), brewing tea or smoking dried plant mate…

**3.** `plants` · *Don't grow it as ornamental* (hybrid=0.85, kw=0.99, vec=0.79) — `plants.datura#5`
  > Some Datura species (like Angel's Trumpet, Brugmansia, which is related) are sold as garden plants because of their dramatic flowers. They are equally toxic. Children eating the seeds is a recurring poisoning pattern. If you have small c…

- _top result hit keywords: ['hallucinogen']_

---

## ✓ [7/100] 'oleander burning brush smoke'

**Safety:** intent=`first_aid` · mode=`locked_procedure` · risk=`high`

**1.** `plants` · *Don't burn oleander* (hybrid=0.90, kw=1.00, vec=0.86) — `plants.oleander#3`
  > A particularly dangerous mode of poisoning: people clearing brush who burn oleander and inhale smoke. The toxins are not destroyed by burning. Smoke inhalation can cause cardiac symptoms identical to ingestion. Never burn oleander branch…

**2.** `plants` · *Why it kills* (hybrid=0.77, kw=0.68, vec=0.80) — `plants.oleander#2`
  > Oleander contains cardiac glycosides (oleandrin and others) chemically similar to digitalis. The mechanism of poisoning is the same — heart rhythm disturbances, cardiac arrest. Reports of fatalities from: eating one leaf as a tea, suckin…

**3.** `plants` · *Where it grows* (hybrid=0.73, kw=0.54, vec=0.81) — `plants.oleander#0`
  > Oleander is a popular ornamental shrub across the southern US — California, Texas, Florida, Arizona, the Gulf Coast — used in highway landscaping and gardens for its hardiness and showy flowers. It's evergreen, drought-tolerant, and grow…

- _top result hit keywords: ['oleander', 'cardiac', 'smoke', 'never burn']_

---

## ✓ [8/100] 'rhododendron toxic to dogs'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Pet danger* (hybrid=0.90, kw=1.00, vec=0.86) — `plants.mountain-laurel-and-rhododendron#5`
  > Dogs that browse on these plants can be severely poisoned. A mouthful of leaves can cause sustained vomiting, weakness, and heart rhythm changes. Don't let dogs forage in dense rhododendron or laurel. If a dog has eaten any amount, conta…

**2.** `plants` · *Why they matter* (hybrid=0.77, kw=0.81, vec=0.75) — `plants.mountain-laurel-and-rhododendron#0`
  > These showy evergreen shrubs dominate large parts of the Appalachian, Pacific Northwest, and Southern US understory. They contain grayanotoxins, which affect the heart and nervous system. Humans rarely die from contact, but children, liv…

**3.** `plants` · *Real-world risk in the backcountry* (hybrid=0.75, kw=0.73, vec=0.76) — `plants.mountain-laurel-and-rhododendron#3`
  > You're rarely poisoned by touching these plants — the risk is eating leaves, flowers, or honey made from them. Children playing in "laurel hells" (dense thickets of mountain laurel) sometimes try the flowers. Wood from these plants, used…

- _top result hit keywords: ['dog', 'vomiting']_

---

## ◐ [9/100] 'mountain laurel poisonous'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Real-world risk in the backcountry* (hybrid=0.85, kw=1.00, vec=0.79) — `plants.mountain-laurel-and-rhododendron#3`
  > You're rarely poisoned by touching these plants — the risk is eating leaves, flowers, or honey made from them. Children playing in "laurel hells" (dense thickets of mountain laurel) sometimes try the flowers. Wood from these plants, used…

**2.** `plants` · *Pet danger* (hybrid=0.80, kw=0.90, vec=0.76) — `plants.mountain-laurel-and-rhododendron#5`
  > Dogs that browse on these plants can be severely poisoned. A mouthful of leaves can cause sustained vomiting, weakness, and heart rhythm changes. Don't let dogs forage in dense rhododendron or laurel. If a dog has eaten any amount, conta…

**3.** `plants` · *"Laurel hell" considerations* (hybrid=0.71, kw=0.59, vec=0.76) — `plants.mountain-laurel-and-rhododendron#6`
  > In the Appalachians, "laurel hells" are thickets so dense you literally cannot walk through them. Camping inside is undesirable for many reasons (no flat ground, no breeze, often wet, snake habitat). The plants themselves aren't dangerou…

- _no expected topic keywords found in top result: ['grayanotoxin', 'kalmia', 'vomiting']_

---

## ✓ [10/100] 'yew berry seed toxic'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *The deceptive berry* (hybrid=0.88, kw=1.00, vec=0.83) — `plants.yew#2`
  > The red flesh of the berry (aril) is actually not toxic — birds eat them and disperse seeds. But the seed inside is extremely toxic, and the rest of the plant is. Children eating "those pretty red berries" and swallowing the seeds get a …

**2.** `plants` · *Why it's dangerous* (hybrid=0.79, kw=0.69, vec=0.83) — `plants.yew#0`
  > Yew (Taxus) is among the most toxic plants in North America. All parts except the red fleshy aril around the seed contain taxine alkaloids, which cause sudden cardiac arrest with little warning. There is no effective antidote and support…

**3.** `plants` · *What's toxic about it* (hybrid=0.74, kw=0.60, vec=0.80) — `plants.pokeweed#2`
  > The toxin (phytolaccin and related compounds) causes severe gastrointestinal symptoms and can affect the heart and nervous system. Toxicity is highest in the root and mature parts; lowest in young spring shoots. Berries are particularly …

- _top result hit keywords: ['deceptive berry']_

---

## ✓ [11/100] 'pokeweed poke salad'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *A confusing plant* (hybrid=0.91, kw=1.00, vec=0.87) — `plants.pokeweed#0`
  > Pokeweed is famous in Southern US foraging traditions ("poke salad," "poke sallet") as a cooked edible — but only the young spring shoots, and only after multiple boilings with water changes. Adult plants, roots, mature stems, leaves pas…

**2.** `plants` · *Tradition vs safety* (hybrid=0.78, kw=0.75, vec=0.79) — `plants.pokeweed#6`
  > Generations of Southerners have eaten "poke salad" safely by harvesting only young spring shoots (under 6 inches) and boiling them three times in fresh water, discarding the water each time. This is a real tradition with real food. It is…

**3.** `food` · *Why this is a hard line* (hybrid=0.60, kw=0.35, vec=0.71) — `food.foraging-caution#1`
  > - **Mushrooms** in particular are deadly to misidentify. The "destroying angel" (*Amanita virosa*) and "death cap" (*Amanita phalloides*) look like edible button mushrooms to non-experts. Symptoms appear 6–24 hours after eating, by which…

- _top result hit keywords: ['boiling', 'southern']_

---

## ✓ [12/100] 'devils club spines pacific northwest'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Pacific Northwest's worst bushwhacking obstacle* (hybrid=0.87, kw=1.00, vec=0.82) — `plants.devils-club#0`
  > Devil's club is a tall deciduous shrub covered in long sharp spines on its stems, branches, leaf petioles, and even leaf veins. It dominates wet understory in old-growth forest from Alaska through coastal British Columbia, Washington, Or…

**2.** `plants` · *Why the spines are nasty* (hybrid=0.80, kw=0.89, vec=0.76) — `plants.devils-club#2`
  > Devil's club spines are barbed and brittle. They break off in skin and don't easily come out. They carry plant compounds and skin bacteria that make wounds inflamed and slow to heal. Bushwhacking through dense stands leaves people with d…

**3.** `plants` · *Bears in devil's club* (hybrid=0.78, kw=0.87, vec=0.75) — `plants.devils-club#6`
  > Devil's club berry stands are favorite black bear and grizzly food in late summer and fall. The combination of dense vegetation that limits sight distance plus a feeding bear is a real safety concern. Make noise constantly while walking …

- _top result hit keywords: ['spines', 'bushwhack']_

---

## ◐ [13/100] 'death cap amanita green mushroom'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Look-alikes that kill people* (hybrid=0.86, kw=0.99, vec=0.80) — `plants.death-cap#2`
  > Inexperienced foragers mistake it for: - **Paddy straw mushroom** (Volvariella volvacea, edible) — also has a volva, but pink spore print and pink-ish gills as it matures. - **Some Russula species** — but Russulas have no ring or volva. …

**2.** `plants` · *Recognize Amanita features* (hybrid=0.86, kw=1.00, vec=0.79) — `plants.wild-mushrooms#2`
  > You should know what Amanitas look like so you can avoid the family entirely. Features: a cup-like volva at the base (often hidden under leaf litter — dig gently to expose), a ring (annulus) on the stem, white gills, often white spore pr…

**3.** `plants` · *The deadliest mushroom in North America* (hybrid=0.84, kw=0.82, vec=0.85) — `plants.death-cap#0`
  > Amanita phalloides is responsible for the vast majority of mushroom poisoning deaths worldwide. Originally European, it has spread across North America, especially the West Coast where it grows under oaks. A single mushroom can kill an a…

- _no expected topic keywords found in top result: ['phalloides', 'amatoxin', 'liver']_

---

## ◐ [14/100] 'destroying angel white mushroom'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *What to do* (hybrid=0.87, kw=0.94, vec=0.84) — `plants.destroying-angel#4`
  > Any suspected destroying angel ingestion is an emergency, regardless of how mild the initial symptoms seem. Call Poison Control immediately. Get to a hospital that can handle hepatotoxic poisoning. Bring the mushroom and any leftovers. A…

**2.** `plants` · *Why it's confused with edibles* (hybrid=0.86, kw=1.00, vec=0.80) — `plants.destroying-angel#2`
  > Inexperienced foragers mistake destroying angels for: - **Button mushrooms / store-bought white mushrooms** (Agaricus bisporus): button mushroom has pink-to-brown gills as it matures, brown spore print, NO ring, NO volva. - **Meadow mush…

**3.** `plants` · *A pure-white killer* (hybrid=0.84, kw=0.95, vec=0.79) — `plants.destroying-angel#0`
  > Destroying angels are a group of pure-white Amanita species (A. virosa, A. bisporigera in the East, A. ocreata in the West) that contain the same amatoxins as the death cap. Pretty, white, looks innocent — and lethal. They grow across th…

- _no expected topic keywords found in top result: ['amanita', 'virosa', 'volva']_

---

## ✓ [15/100] 'false morel gyromitra'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Dried false morels are NOT safer* (hybrid=0.86, kw=1.00, vec=0.81) — `plants.false-morel#4`
  > A common misconception: drying false morels reduces MMH. It does, somewhat — but unevenly, unpredictably, and people have died from rehydrated dried false morels. Commercial sales of dried Gyromitra are banned in many countries. If a for…

**2.** `plants` · *True morels vs false morels* (hybrid=0.82, kw=1.00, vec=0.75) — `plants.false-morel#0`
  > Morel mushrooms (Morchella species) are highly prized edible mushrooms with a distinctive honeycomb cap. False morels (Gyromitra species, especially Gyromitra esculenta) look superficially similar to inexperienced foragers but contain mo…

**3.** `plants` · *The cooking myth* (hybrid=0.71, kw=0.77, vec=0.68) — `plants.false-morel#3`
  > Folk tradition holds that boiling false morels in water (and discarding the water) detoxifies them. The toxin is volatile and can be partially removed this way. However: residual toxin levels are unpredictable, the steam itself can poiso…

- _top result hit keywords: ['gyromitra']_

---

## ✓ [16/100] 'wild parsnip burn skin sap'

**Safety:** intent=`first_aid` · mode=`locked_procedure` · risk=`high`

**1.** `plants` · *Avoiding it* (hybrid=0.90, kw=1.00, vec=0.85) — `plants.wild-parsnip#5`
  > Long pants, long sleeves, gloves when in known wild parsnip areas. Don't pull or cut wild parsnip without full coverage. Don't weed-whack it — the sap aerosolizes onto skin. If you must remove it (it's a problem invasive in many states),…

**2.** `plants` · *Why it matters* (hybrid=0.88, kw=0.95, vec=0.85) — `plants.wild-parsnip#0`
  > Wild parsnip is invasive across the upper Midwest, Northeast, and parts of the Pacific Northwest. The plant's sap contains furanocoumarins — chemicals that, when activated by sunlight on skin, cause severe burns and blisters that look li…

**3.** `plants` · *Giant hogweed (Heracleum mantegazzianum) — phytophotodermatitis* (hybrid=0.83, kw=0.80, vec=0.84) — `plants.dangerous-plants#1`
  > An invasive plant spreading through the northeastern and northwestern U.S. Tall (8–14 feet at maturity), with massive umbrella-shaped white flower clusters (up to 2.5 feet across), deeply lobed leaves, and a thick stem with purple blotch…

- _top result hit keywords: ['sun']_

---

## ✓ [17/100] 'poison hemlock purple spots'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Poison hemlock identification* (hybrid=0.75, kw=1.00, vec=0.64) — `plants.poison-hemlock#1`
  > A tall plant (3–10 feet at maturity), with smooth hollow stems marked by distinctive purple-red spots or streaks (no other carrot-family plant has these). Leaves are finely divided, fern-like. White flowers in umbrella-shaped clusters in…

**2.** `plants` · *Poison hemlock (Conium maculatum) — historic poison of Socrates* (hybrid=0.71, kw=0.74, vec=0.70) — `plants.dangerous-plants#3`
  > Tall (3–10 feet), white umbrella flowers, fern-like leaves, **smooth stem with purple blotches** (distinguishing it from Queen Anne's lace, which has hairy stems). All parts are toxic. Symptoms: weakness, paralysis, respiratory failure. …

**3.** `plants` · *Identification* (hybrid=0.69, kw=0.69, vec=0.69) — `plants.water-hemlock#1`
  > 2–6 feet tall (smaller than poison hemlock). Hollow stems often streaked or splotched purple at the base. Leaves pinnately compound, sharply toothed, with veins ending in the NOTCHES between teeth rather than in the teeth themselves — a …

- _top result hit keywords: ['hemlock', 'purple']_

---

## ✓ [18/100] 'giant hogweed sap burn'

**Safety:** intent=`first_aid` · mode=`locked_procedure` · risk=`high`

**1.** `plants` · *Why it's dangerous* (hybrid=0.92, kw=1.00, vec=0.88) — `plants.giant-hogweed#0`
  > Giant hogweed (Heracleum mantegazzianum) is an invasive species in the northeastern US, Pacific Northwest, and parts of Canada. Its sap contains chemicals (furanocoumarins) that, on contact with skin then exposure to sunlight, cause seve…

**2.** `plants` · *Avoiding it* (hybrid=0.83, kw=0.90, vec=0.80) — `plants.giant-hogweed#4`
  > Long pants, long sleeves, gloves when working in known-infested areas. Identify before you touch any tall plant with umbrella-shaped flowers. Children should be specifically taught what it looks like. Report giant hogweed to local/state …

**3.** `plants` · *Why it matters* (hybrid=0.82, kw=0.95, vec=0.76) — `plants.wild-parsnip#0`
  > Wild parsnip is invasive across the upper Midwest, Northeast, and parts of the Pacific Northwest. The plant's sap contains furanocoumarins — chemicals that, when activated by sunlight on skin, cause severe burns and blisters that look li…

- _top result hit keywords: ['hogweed', 'burn']_

---

## ✓ [19/100] 'manchineel beach Florida'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Where it lives* (hybrid=0.85, kw=1.00, vec=0.79) — `plants.manchineel#0`
  > Manchineel (Hippomane mancinella) grows along Caribbean and Atlantic coasts including the Florida Keys, southern coastal Florida, parts of the Bahamas, much of the Caribbean, and northern South America. It's a medium-sized evergreen tree…

**2.** `plants` · *Identification* (hybrid=0.80, kw=0.90, vec=0.75) — `plants.manchineel#1`
  > A tree 20–50 feet tall with small, oval, glossy green leaves and small greenish-yellow flowers. Fruit looks like small green apples — 1–2 inches across, sometimes ripening yellow. Bark is grayish, becoming reddish in cracks. Often found …

**3.** `plants` · *If you contact sap* (hybrid=0.58, kw=0.47, vec=0.62) — `plants.manchineel#4`
  > Wash skin thoroughly with soap and water, multiple times. Cool compresses for pain and blistering. Severe contact, contact with eyes, or any ingestion is a medical emergency — evacuate to care. Contact dermatitis can develop hours after …

- _top result hit keywords: ['manchineel', 'Caribbean']_

---

## ✓ [20/100] 'poison ivy three leaves'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Identification* (hybrid=0.93, kw=1.00, vec=0.90) — `plants.poison-ivy-oak-sumac#0`
  > Poison ivy: "leaves of three, let it be." Three leaflets per stem, with the center leaflet on a longer stalk than the two side leaflets. Edges can be smooth or notched but never serrated like blackberry. Reddish in spring, green in summe…

**2.** `plants` · *Burning is dangerous* (hybrid=0.74, kw=0.65, vec=0.78) — `plants.poison-ivy-oak-sumac#3`
  > Never burn poison ivy, oak, or sumac. The urushiol vaporizes into smoke and can be inhaled, causing reactions in the lungs and airways that have killed people. Pull plants by hand only in heavy gloves you can dispose of, and bag the plan…

**3.** `plants` · *Overview* (hybrid=0.68, kw=0.43, vec=0.78) — `plants.dangerous-plants#0`
  > Beyond the poison ivy/oak/sumac family and stinging nettle, North American hikers should be aware of several plants that cause severe injury or death. The single best rule: **do not eat, do not touch, do not burn** any plant you cannot i…

- _top result hit keywords: ['leaves of three']_

---

## ✓ [21/100] 'western diamondback rattlesnake Texas'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Range and species* (hybrid=0.89, kw=1.00, vec=0.85) — `wildlife.rattlesnakes#0`
  > Rattlesnakes (genera Crotalus and Sistrurus) inhabit every state in the lower 48 except Maine, Delaware, and possibly Rhode Island, plus parts of southern Canada and most of Mexico. The most clinically significant species: - **Western di…

**2.** `wildlife` · *Range and habitat* (hybrid=0.64, kw=0.33, vec=0.78) — `wildlife.copperhead#0`
  > Copperheads inhabit the eastern and central US — from southern New England through Florida (excluding the tip), west to Texas and parts of the Midwest. They're the most common venomous snake bite in the eastern US (more bites than rattle…

**3.** `wildlife` · *Range and species* (hybrid=0.61, kw=0.17, vec=0.80) — `wildlife.coral-snake#1`
  > **Eastern coral snake** (Micrurus fulvius) — Coastal plain from North Carolina through Florida and west to Louisiana. Most encountered species. **Texas coral snake** (M. tener) — Texas, Arkansas, Louisiana. Similar venom and behavior. **…

- _top result hit keywords: ['rattlesnake']_

---

## ✓ [22/100] 'timber rattlesnake eastern'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Range and species* (hybrid=0.85, kw=1.00, vec=0.78) — `wildlife.rattlesnakes#0`
  > Rattlesnakes (genera Crotalus and Sistrurus) inhabit every state in the lower 48 except Maine, Delaware, and possibly Rhode Island, plus parts of southern Canada and most of Mexico. The most clinically significant species: - **Western di…

**2.** `wildlife` · *Range and habitat* (hybrid=0.67, kw=0.54, vec=0.73) — `wildlife.copperhead#0`
  > Copperheads inhabit the eastern and central US — from southern New England through Florida (excluding the tip), west to Texas and parts of the Midwest. They're the most common venomous snake bite in the eastern US (more bites than rattle…

**3.** `wildlife` · *Identification (North America)* (hybrid=0.62, kw=0.43, vec=0.70) — `wildlife.snakes#1`
  > The four medically significant venomous snake families in the U.S.: rattlesnakes (multiple species, rattle on tail, broad triangular head, distinct pit between eye and nostril), copperheads (eastern U.S., copper-bronze color, hourglass c…

- _top result hit keywords: ['rattlesnake', 'timber', 'eastern']_

---

## ✓ [23/100] 'Mojave rattlesnake neurotoxic venom'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Range and species* (hybrid=0.84, kw=1.00, vec=0.77) — `wildlife.rattlesnakes#0`
  > Rattlesnakes (genera Crotalus and Sistrurus) inhabit every state in the lower 48 except Maine, Delaware, and possibly Rhode Island, plus parts of southern Canada and most of Mexico. The most clinically significant species: - **Western di…

**2.** `wildlife` · *A different venom family* (hybrid=0.78, kw=0.72, vec=0.80) — `wildlife.coral-snake#0`
  > Coral snakes are the only elapids native to the US — same family as cobras and mambas, with neurotoxic venom that paralyzes muscles. This is different from rattlesnakes/copperheads/cottonmouths (pit vipers with hemotoxic venom). Coral sn…

**3.** `wildlife` · *Identification (North America)* (hybrid=0.68, kw=0.39, vec=0.81) — `wildlife.snakes#1`
  > The four medically significant venomous snake families in the U.S.: rattlesnakes (multiple species, rattle on tail, broad triangular head, distinct pit between eye and nostril), copperheads (eastern U.S., copper-bronze color, hourglass c…

- _top result hit keywords: ['Mojave', 'neurotoxic', 'venom']_

---

## ✓ [24/100] 'copperhead snake hourglass markings'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Identification (North America)* (hybrid=0.83, kw=1.00, vec=0.76) — `wildlife.snakes#1`
  > The four medically significant venomous snake families in the U.S.: rattlesnakes (multiple species, rattle on tail, broad triangular head, distinct pit between eye and nostril), copperheads (eastern U.S., copper-bronze color, hourglass c…

**2.** `wildlife` · *Identification* (hybrid=0.83, kw=0.86, vec=0.81) — `wildlife.copperhead#1`
  > Adults 2–3 feet. Coppery-tan to pale brown background color with distinct dark hourglass-shaped crossbands — narrow at the spine, wide on the sides (some say "Hershey Kiss" shaped). Head distinctly triangular, copper-colored on top givin…

**3.** `wildlife` · *Field response* (hybrid=0.77, kw=0.90, vec=0.71) — `wildlife.copperhead#4`
  > Same as for any pit viper bite (see wildlife.rattlesnakes): - Move away from the snake. - Sit or lie down, keep calm. - Remove jewelry and tight clothing from the bitten area. - Keep the limb at heart level. - Mark the leading edge of sw…

- _top result hit keywords: ['copperhead', 'hourglass']_

---

## ✓ [25/100] 'cottonmouth water moccasin swamp'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Range and habitat* (hybrid=0.88, kw=1.00, vec=0.83) — `wildlife.cottonmouth#0`
  > The cottonmouth is the only venomous water snake in the US, ranging across the southeastern coastal plain from Virginia through Florida and west to eastern Texas, plus the Mississippi River valley up to southern Illinois. They live in sl…

**2.** `wildlife` · *Distinguishing from harmless water snakes* (hybrid=0.79, kw=0.85, vec=0.77) — `wildlife.cottonmouth#2`
  > Many harmless water snakes share their habitat and get killed by people misidentifying them. Key differences: - **Cottonmouth swims with body partly out of water** (buoyant due to lung position); harmless water snakes (Nerodia species) s…

**3.** `wildlife` · *Behavior* (hybrid=0.77, kw=0.83, vec=0.74) — `wildlife.cottonmouth#3`
  > Cottonmouths have a reputation for aggression that's somewhat exaggerated — they prefer to display threats (open mouth, vibrating tail) rather than strike. But they're more willing to stand their ground than most US snakes, and they're f…

- _top result hit keywords: ['cottonmouth', 'swamp']_

---

## ✓ [26/100] 'coral snake red yellow black'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Identification — "red touches yellow"* (hybrid=0.91, kw=1.00, vec=0.87) — `wildlife.coral-snake#2`
  > The classic North American mnemonic: **"Red touches yellow, kill a fellow. Red touches black, friend of Jack."** Coral snakes have red, yellow, and black bands in repeating order with RED touching YELLOW. Harmless mimics (king snakes, sc…

**2.** `wildlife` · *Identification (North America)* (hybrid=0.85, kw=0.89, vec=0.84) — `wildlife.snakes#1`
  > The four medically significant venomous snake families in the U.S.: rattlesnakes (multiple species, rattle on tail, broad triangular head, distinct pit between eye and nostril), copperheads (eastern U.S., copper-bronze color, hourglass c…

**3.** `wildlife` · *Avoiding bites* (hybrid=0.80, kw=0.70, vec=0.84) — `wildlife.coral-snake#7`
  > Don't pick up any snake you can't ID with 100% certainty. The red-touches-yellow rule is reliable in the US but only if you can see the bands clearly. In good light, a coral snake is unmistakable. In poor light or rushed, mistakes happen…

- _top result hit keywords: ['coral', 'red touches yellow']_

---

## ✓ [27/100] 'black widow spider bite cramps'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Medically significant US spiders* (hybrid=0.89, kw=0.95, vec=0.87) — `wildlife.spiders-and-scorpions#0`
  > **Black widow** (Latrodectus species) — shiny black with red hourglass on the underside of the abdomen, common across the lower 48. Bite causes severe muscle cramps, especially in the abdomen, sometimes mistaken for appendicitis. Sweatin…

**2.** `wildlife` · *When to evacuate* (hybrid=0.84, kw=1.00, vec=0.77) — `wildlife.spiders-and-scorpions#4`
  > Evacuate immediately for: any signs of anaphylaxis (rare but possible), suspected bark-scorpion sting in a child, suspected black-widow bite with severe abdominal pain or muscle cramping, brown-recluse bite with rapidly spreading dark ti…

**3.** `wildlife` · *Behavior and bites* (hybrid=0.80, kw=0.73, vec=0.83) — `wildlife.black-widow#2`
  > Black widows are not aggressive — they bite defensively when pressed against skin. Most bites occur when reaching into a dark space (woodpiles, gloves, boots) where a widow has set up. The web is irregular, three-dimensional, often near …

- _top result hit keywords: ['black widow', 'latrodectus', 'hourglass']_

---

## ✓ [28/100] 'brown recluse violin spider'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Identification* (hybrid=0.88, kw=1.00, vec=0.82) — `wildlife.brown-recluse#1`
  > Small spider, body 1/4 to 1/2 inch long, leg span up to 1.5 inches. Tan to dark brown, sometimes pale yellow-tan. The diagnostic feature is the violin-shaped marking on the back (cephalothorax), with the violin's "neck" pointing toward t…

**2.** `wildlife` · *Medically significant US spiders* (hybrid=0.83, kw=0.89, vec=0.80) — `wildlife.spiders-and-scorpions#0`
  > **Black widow** (Latrodectus species) — shiny black with red hourglass on the underside of the abdomen, common across the lower 48. Bite causes severe muscle cramps, especially in the abdomen, sometimes mistaken for appendicitis. Sweatin…

**3.** `wildlife` · *Diagnostic skepticism* (hybrid=0.78, kw=0.70, vec=0.82) — `wildlife.brown-recluse#5`
  > Studies have found that the great majority of "brown recluse bite" diagnoses outside the spider's range are actually MRSA, other skin infections, vasculitis, or other conditions. Even within the range, many supposed bites are misdiagnose…

- _top result hit keywords: ['violin']_

---

## ✓ [29/100] 'Arizona bark scorpion sting child'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Children and severe cases* (hybrid=0.87, kw=1.00, vec=0.82) — `wildlife.bark-scorpion#4`
  > Children under 6 are at much higher risk for severe systemic symptoms. A bark scorpion sting on a small child can be a true emergency. Symptoms in kids: sudden inability to sit still, abnormal eye movements, drooling, sometimes vomiting,…

**2.** `wildlife` · *The only medically dangerous US scorpion* (hybrid=0.85, kw=0.83, vec=0.86) — `wildlife.bark-scorpion#0`
  > Out of roughly 90 scorpion species in the US, the Arizona bark scorpion is the only one whose sting routinely causes severe systemic symptoms in healthy adults and is occasionally fatal. Range: Arizona (especially central and southern), …

**3.** `wildlife` · *Treatment* (hybrid=0.83, kw=0.98, vec=0.77) — `wildlife.bark-scorpion#5`
  > Wash the sting area. Cool compress for pain. For mild cases in healthy adults: rest, OTC pain reliever per label, monitor. Evacuate to medical care for: any child under 6 with sting symptoms, any sting with rapid onset of severe systemic…

- _top result hit keywords: ['bark scorpion', 'child']_

---

## ✓ [30/100] 'bison charge Yellowstone tourist'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *In a vehicle* (hybrid=0.91, kw=0.99, vec=0.88) — `wildlife.bison#5`
  > Bison on roads in Yellowstone is a daily traffic phenomenon. Stay in your vehicle. Drive slowly past — if the herd is on the road, wait it out; don't push through. Don't honk to clear them; agitated bison can charge a vehicle (and someti…

**2.** `wildlife` · *The selfie problem* (hybrid=0.85, kw=1.00, vec=0.79) — `wildlife.bison#7`
  > Most bison injuries in parks happen to visitors who approached too close for photos. Tourists from areas without dangerous wildlife consistently misjudge bison behavior — they look like big cows, but they aren't. Rangers and signs repeat…

**3.** `wildlife` · *Bison charges* (hybrid=0.83, kw=0.91, vec=0.79) — `wildlife.bison#3`
  > Once a bison commits to a charge, you have very little time. Get behind something solid — a vehicle, a large tree, a boulder. Bison charging lines are mostly straight forward, so running 90° to the side is more effective than running dir…

- _top result hit keywords: ['bison', 'Yellowstone']_

---

## ✓ [31/100] 'elk in rut bull'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *In rut, in town* (hybrid=0.91, kw=1.00, vec=0.87) — `wildlife.elk#3`
  > Estes Park, Banff, Jasper, and similar towns have habituated elk that lounge on lawns and golf courses. Don't take selfies. Don't walk between a bull and his cows. Don't approach calves. Bulls have attacked people in their yards, charged…

**2.** `wildlife` · *Elk charges* (hybrid=0.87, kw=0.93, vec=0.84) — `wildlife.elk#4`
  > Same general response as bison: get behind solid cover, run perpendicular to the charge line not straight away, climb if needed (large tree, vehicle, structure). Elk are slightly less massive than bison but have antlers (bulls) and clove…

**3.** `wildlife` · *Range and habitat* (hybrid=0.85, kw=0.88, vec=0.83) — `wildlife.elk#0`
  > Wild elk in the Rocky Mountains (CO, WY, MT, ID, NM), Pacific Northwest (WA, OR), parts of California, Arizona, Utah, and reintroduced populations in PA, KY, NC, VA, AR, TN, MI, WI. Bulls are 700–1,000 pounds with massive antlers (in rut…

- _top result hit keywords: ['elk', 'rut']_

---

## ✓ [32/100] 'polar bear alaska arctic'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *A different bear* (hybrid=0.89, kw=1.00, vec=0.84) — `wildlife.polar-bear#0`
  > Polar bears are unlike other US bears in two critical ways: they are obligate carnivores (other bears are omnivores) and they actively hunt humans on rare occasions, considering us prey rather than threats to defend against. Polar bear a…

**2.** `wildlife` · *Where you might encounter them* (hybrid=0.86, kw=0.95, vec=0.82) — `wildlife.polar-bear#1`
  > Most travelers won't. Polar bears live on sea ice and along Arctic coastlines. Backpackers in ANWR, Gates of the Arctic NP, the North Slope, Kotzebue, Barrow/Utqiagvik, and small Arctic villages may encounter them. Hunters traveling Arct…

**3.** `wildlife` · *Climate-driven changes* (hybrid=0.83, kw=0.87, vec=0.82) — `wildlife.polar-bear#2`
  > Sea ice loss has changed polar bear behavior over recent decades. Bears now spend more time on land, are often thin and hungry, and travel further inland searching for food. Human-bear conflicts have increased in coastal Arctic villages.…

- _top result hit keywords: ['polar bear']_

---

## ✓ [33/100] 'grizzly bear vs black bear'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Why this matters* (hybrid=0.86, kw=1.00, vec=0.80) — `wildlife.black-vs-grizzly-id#6`
  > Defensive grizzly attacks and defensive black bear attacks require **opposite** responses (play dead vs. fight back). In practice, surprise encounters are chaotic and species identification can be uncertain. When unsure: deploy bear spra…

**2.** `wildlife` · *Black bear vs grizzly (brown) bear* (hybrid=0.84, kw=0.91, vec=0.80) — `wildlife.bears#0`
  > Black bears are common across most of North America, including the East Coast and Southeast. They are usually smaller (150–400 lb), tend to be more skittish around humans, and rarely act predatorily toward adults. Their face profile is s…

**3.** `wildlife` · *Overview* (hybrid=0.80, kw=0.79, vec=0.80) — `wildlife.black-vs-grizzly-id#0`
  > Color is unreliable — black bears can be brown, blond, or cinnamon, and grizzlies range from blond to nearly black. Use body shape and face profile instead.

- _top result hit keywords: ['grizzly']_

---

## ✓ [34/100] 'mosquito west nile virus'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Why they kill more people than any other animal* (hybrid=0.88, kw=1.00, vec=0.82) — `wildlife.mosquito-disease#0`
  > Globally, mosquitoes cause more human deaths than any other animal — primarily through malaria. In the US, mosquito-borne diseases of concern include West Nile virus (most common, nationwide), Eastern equine encephalitis (rare, Northeast…

**2.** `wildlife` · *Why they matter more than the bite* (hybrid=0.85, kw=0.97, vec=0.80) — `wildlife.ticks-disease-vectors#0`
  > Mosquitoes are the deadliest animal on earth by direct count, mostly via malaria worldwide. In the US, mosquitoes spread West Nile virus, Eastern equine encephalitis, La Crosse, and locally-acquired Zika. Ticks spread Lyme disease (the m…

**3.** `wildlife` · *Recognizing a mosquito-borne illness* (hybrid=0.79, kw=0.63, vec=0.86) — `wildlife.mosquito-disease#4`
  > Most West Nile infections are asymptomatic, but a small percentage develop serious neuroinvasive disease — high fever, severe headache, stiff neck, confusion, weakness, sometimes paralysis. EEE has very high mortality and warrants immedi…

- _top result hit keywords: ['west nile']_

---

## ✓ [35/100] 'jellyfish sting vinegar'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Field treatment* (hybrid=0.90, kw=1.00, vec=0.85) — `wildlife.jellyfish-and-stings#2`
  > 1. **Get out of the water** without panicking — splashing or swimming dragging tentacles spreads the sting. 2. **Carefully remove visible tentacle pieces** — wear gloves, use tweezers, or scrape with the edge of a card. Do NOT rub with h…

**2.** `wildlife` · *US species of concern* (hybrid=0.77, kw=0.68, vec=0.81) — `wildlife.jellyfish-and-stings#0`
  > Most US jellyfish stings are painful but not dangerous. Notable exceptions: - **Portuguese man o' war** (not technically a jellyfish but a siphonophore) — Gulf, southeast Atlantic, sometimes Pacific. Long blue tentacles, severe sting, oc…

**3.** `wildlife` · *How they sting* (hybrid=0.75, kw=0.65, vec=0.79) — `wildlife.jellyfish-and-stings#1`
  > Jellyfish tentacles have stinging cells (nematocysts) that fire when triggered by contact or chemical stimulus. Dead or detached tentacles still sting — washed up tentacles on beaches sting bare feet. The toxin causes pain, redness, welt…

- _top result hit keywords: ['jellyfish', 'vinegar', 'hot water']_

---

## ✓ [36/100] 'stingray foot sting'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Stingrays* (hybrid=0.83, kw=0.88, vec=0.81) — `wildlife.jellyfish-and-stings#4`
  > Stingrays are not jellyfish, but the treatment overlaps. Stingrays lie partly buried in shallow sand; people step on them, and the barbed spine on the tail whips into the foot or ankle. Pain is severe, often described as the worst pain t…

**2.** `wildlife` · *Sea urchins, coral, fire coral* (hybrid=0.78, kw=1.00, vec=0.68) — `wildlife.jellyfish-and-stings#7`
  > Stepping on sea urchins in tide pools or reef areas: spines stick in the foot, often break off. Soak in hot vinegar to dissolve spine fragments, then remove with tweezers. Embedded fragments often work out over weeks. Don't grind tongue …

**3.** `wildlife` · *How they sting* (hybrid=0.77, kw=0.80, vec=0.76) — `wildlife.jellyfish-and-stings#1`
  > Jellyfish tentacles have stinging cells (nematocysts) that fire when triggered by contact or chemical stimulus. Dead or detached tentacles still sting — washed up tentacles on beaches sting bare feet. The toxin causes pain, redness, welt…

- _top result hit keywords: ['stingray', 'hot water']_

---

## ✓ [37/100] 'Portuguese man o war blue tentacle'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *US species of concern* (hybrid=0.72, kw=1.00, vec=0.61) — `wildlife.jellyfish-and-stings#0`
  > Most US jellyfish stings are painful but not dangerous. Notable exceptions: - **Portuguese man o' war** (not technically a jellyfish but a siphonophore) — Gulf, southeast Atlantic, sometimes Pacific. Long blue tentacles, severe sting, oc…

**2.** `wildlife` · *Field treatment* (hybrid=0.66, kw=0.81, vec=0.60) — `wildlife.jellyfish-and-stings#2`
  > 1. **Get out of the water** without panicking — splashing or swimming dragging tentacles spreads the sting. 2. **Carefully remove visible tentacle pieces** — wear gloves, use tweezers, or scrape with the edge of a card. Do NOT rub with h…

**3.** `wildlife` · *How they sting* (hybrid=0.64, kw=0.81, vec=0.57) — `wildlife.jellyfish-and-stings#1`
  > Jellyfish tentacles have stinging cells (nematocysts) that fire when triggered by contact or chemical stimulus. Dead or detached tentacles still sting — washed up tentacles on beaches sting bare feet. The toxin causes pain, redness, welt…

- _top result hit keywords: ['tentacle', 'sting']_

---

## ◐ [38/100] 'tick remove with tweezers'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Equipment* (hybrid=0.94, kw=1.00, vec=0.92) — `first-aid.tick-removal#1`
  > The right tool is **fine-tipped tweezers** (sharper than household tweezers) or a purpose-built tick-removal tool (small notched plastic key style). If neither is available, regular tweezers work. Avoid using your fingers if possible — f…

**2.** `first-aid` · *Tick bites and removal* (hybrid=0.84, kw=0.76, vec=0.88) — `first-aid.bites-stings#1`
  > Use fine-tipped tweezers to grasp the tick as close to the skin as possible. Pull straight up with steady, even pressure — do not twist or jerk, which can break off mouthparts. Once removed, clean the bite area and your hands with soap a…

**3.** `wildlife` · *Removing an attached tick* (hybrid=0.82, kw=0.74, vec=0.85) — `wildlife.ticks-disease-vectors#3`
  > Use fine-tipped tweezers, grasp the tick as close to the skin as possible, pull straight up with steady firm pressure. Don't twist or jerk — mouth parts may break off and stay in the skin (these don't transmit disease but can cause local…

- _right domain but #3, not top_
- _top result hit keywords: ['tick', 'tweezers']_

---

## ✓ [39/100] 'alligator near campsite'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Don't approach* (hybrid=0.83, kw=0.95, vec=0.78) — `wildlife.alligators-and-crocodiles#1`
  > Adult alligators are 8–14 feet long and 500+ pounds, and can short-burst sprint to 30 mph for 10–20 feet. They feed by ambush, lunging from water onto banks. Stay at least 50–60 feet from any alligator. The shoreline of any southeastern …

**2.** `wildlife` · *In the water* (hybrid=0.83, kw=1.00, vec=0.76) — `wildlife.alligators-and-crocodiles#4`
  > The most dangerous places are: dusk through dawn (alligators feed most actively), shallow water with overhanging vegetation, near nesting areas. Don't swim in any natural water in alligator country unless it's posted as safe. Don't wade …

**3.** `wildlife` · *Where they live* (hybrid=0.80, kw=0.83, vec=0.79) — `wildlife.alligators-and-crocodiles#0`
  > American alligators range across the southeastern US: Florida, Louisiana, Georgia, South Carolina, Alabama, Mississippi, and parts of Texas, Arkansas, North Carolina, and Oklahoma. They live in fresh and slightly brackish water — swamps,…

- _top result hit keywords: ['alligator', 'feed']_

---

## ✓ [40/100] 'moose calf cow protective'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *When moose are most dangerous* (hybrid=0.91, kw=1.00, vec=0.88) — `wildlife.moose#1`
  > A cow with a calf is the most dangerous scenario. Cow moose vigorously defend calves and will charge anyone they perceive as a threat, including hikers, dogs, and other animals. Bull moose during the autumn rut are also unpredictable. Wi…

**2.** `wildlife` · *Calves and protective cows* (hybrid=0.83, kw=0.85, vec=0.83) — `wildlife.bison#6`
  > Late spring through summer, cow bison are highly protective of calves. Walking between a cow and a calf will trigger a charge. Hikers crossing meadows with scattered bison need to know whether calves are present and route widely around a…

**3.** `wildlife` · *If a moose charges* (hybrid=0.80, kw=0.74, vec=0.83) — `wildlife.moose-and-large-ungulates#2`
  > Run. This is the exception — unlike bears and mountain lions, you run from moose. Get behind a substantial tree (trees a moose can't easily knock down) or other solid obstacle. Moose charge to dislodge a threat, not to kill, and will usu…

- _top result hit keywords: ['moose', 'cow', 'calf', 'charge']_

---

## ✓ [41/100] 'mountain lion stalking attack'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *How rare attacks are — and why it matters* (hybrid=0.89, kw=1.00, vec=0.85) — `wildlife.mountain-lions#0`
  > Mountain lion attacks on humans are very rare; in a typical year there are only a handful in all of North America. But mountain lions are obligate ambush predators: when they do attack, they target the head and neck and aim to kill quick…

**2.** `wildlife` · *Reducing the risk* (hybrid=0.84, kw=0.90, vec=0.81) — `wildlife.mountain-lion#4`
  > - Hike in groups when possible. Cougars almost exclusively attack lone people. - Avoid hiking alone at dawn, dusk, or night in known lion habitat. - Keep children close and within arm's reach on trails. - Make noise around blind corners …

**3.** `wildlife` · *If a mountain lion attacks* (hybrid=0.82, kw=0.87, vec=0.80) — `wildlife.mountain-lions#3`
  > Fight back, immediately and aggressively. Most successful self-defenses against mountain lions involve the victim striking the lion's face, eyes, and nose with whatever is available — rocks, sticks, a knife, fists, trekking poles. Try to…

- _top result hit keywords: ['mountain lion', 'look big']_

---

## ✓ [42/100] 'raccoon stealing food cooler'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Raccoons* (hybrid=0.88, kw=1.00, vec=0.83) — `wildlife.raccoons-and-rodents#0`
  > Raccoons are highly intelligent, have hands as dexterous as monkeys, and have learned that humans = food. They open coolers, untie food bags, manipulate latches, and work in pairs at popular campgrounds. They also carry roundworm, rabies…

**2.** `wildlife` · *Threats from small raiders* (hybrid=0.72, kw=0.68, vec=0.74) — `wildlife.small-raiders#1`
  > - **Raccoons** in campgrounds will open coolers, unzip packs, and remember which campers are careless. They are intelligent and dexterous. - **Marmots** in alpine zones chew on rubber, leather, and sweat-soaked gear (boot insoles, pack s…

**3.** `food` · *A note on coolers and vehicles* (hybrid=0.65, kw=0.54, vec=0.70) — `food.cooking-in-bear-country#5`
  > In car-camping, coolers are **not** bear-resistant. A black bear can pop a cooler open in seconds and routinely peels back car windows for food smells. Use the campground's bear locker, no exceptions. A car with food in it parked at a tr…

- _top result hit keywords: ['raccoon', 'store', 'latch']_

---

## ✓ [43/100] 'wolf following hiker'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *Wolves* (hybrid=0.87, kw=1.00, vec=0.81) — `wildlife.coyotes-and-wolves#1`
  > Wolf attacks on humans in North America are vanishingly rare; you have a far higher chance of being attacked by a domestic dog. Wolves in Yellowstone, Glacier, the Boundary Waters, parts of Idaho, Montana, Wyoming, the Cascades, Alaska, …

**2.** `wildlife` · *Foxes* (hybrid=0.67, kw=0.66, vec=0.68) — `wildlife.coyotes-and-wolves#2`
  > Foxes are smaller and rarely a threat to adult humans, but they can carry rabies and steal food. A fox following you in daylight or approaching close is unusual behavior — could be habituated, could be sick. Never feed them, never let ki…

**3.** `trip-basics` · *Stay warm, stay hydrated* (hybrid=0.58, kw=0.28, vec=0.70) — `trip-basics.if-you-get-lost#6`
  > Most search-and-rescue fatalities are hypothermia, not injury. Insulate from the ground. Drink water. Eat if you have food.  Search teams find lost hikers faster than panicked hikers find themselves. Help them find you by staying calm, s…

- _top result hit keywords: ['wolf', 'stand tall', 'group']_

---

## ✓ [44/100] 'bat rabies bedroom exposure'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Why bat exposures matter* (hybrid=0.91, kw=1.00, vec=0.87) — `wildlife.bats-and-rabies#0`
  > Rabies is nearly 100% fatal once symptoms appear, but completely preventable with timely post-exposure prophylaxis. In the US, bats are the most common source of human rabies. Bat bites can be tiny — sometimes invisible — and rabid bats …

**2.** `wildlife` · *After contact* (hybrid=0.83, kw=0.94, vec=0.78) — `wildlife.bats-and-rabies#2`
  > Wash any bite or scratch immediately with soap and water for 15 minutes. This alone significantly reduces rabies risk. Evacuate to medical care — rabies post-exposure prophylaxis (PEP) is a series of vaccines and immunoglobulin given ove…

**3.** `wildlife` · *Prevention* (hybrid=0.83, kw=0.84, vec=0.82) — `wildlife.bats-and-rabies#5`
  > Sleep in tents with sealed mesh and zipped doors. Don't sleep outside without a head net in bat country (caves, forested areas, abandoned buildings). Pre-trip rabies vaccination is recommended for cave explorers, wildlife workers, and pe…

- _top result hit keywords: ['bat', 'rabies', 'exposure']_

---

## ✓ [45/100] 'skunk sprayed my dog'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Skunks* (hybrid=0.89, kw=1.00, vec=0.84) — `wildlife.raccoons-and-rodents#4`
  > Smell makes them famous; they also bite and carry rabies. A skunk approaching a camp wants food — secure food properly. Don't corner a skunk; back away slowly. Sprayed gear: tomato juice is myth, doesn't work. Mix of hydrogen peroxide + …

**2.** `wildlife` · *Other rabies-vector mammals* (hybrid=0.64, kw=0.55, vec=0.67) — `wildlife.bats-and-rabies#3`
  > In the US, raccoons, skunks, foxes, and unvaccinated cats and dogs are also rabies vectors. Any wild mammal acting unusually friendly, aggressive, or disoriented should be considered potentially rabid. Avoid all wild mammals, even ones t…

**3.** `wildlife` · *Reducing the risk* (hybrid=0.58, kw=0.44, vec=0.64) — `wildlife.moose#5`
  > - Maintain at least 25 yards (about 23 m) of distance from any moose, even one that looks calm. - Never approach calves; the cow is always nearby and watching. - Keep dogs leashed; off-leash dogs are a leading cause of moose-on-human att…

- _top result hit keywords: ['skunk', 'hydrogen peroxide', 'baking soda']_

---

## ✓ [46/100] 'alpine butterfly mid rope knot'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *What it does* (hybrid=0.93, kw=1.00, vec=0.91) — `knots.alpine-butterfly#0`
  > The alpine butterfly creates a strong, secure loop in the middle of a rope without using the ends. It's the standard knot for the middle climber on a glacier rope team, for isolating a damaged section of rope, for clipping to a fixed poi…

**2.** `knots` · *Strength and reliability* (hybrid=0.90, kw=0.95, vec=0.87) — `knots.alpine-butterfly#5`
  > The alpine butterfly retains about 60–70% of rope strength, comparable to most other climbing knots (knots universally weaken ropes; this is expected). It's symmetric — loads from both ends behave identically. It doesn't capsize or roll.…

**3.** `knots` · *Use in glacier travel* (hybrid=0.86, kw=0.91, vec=0.83) — `knots.alpine-butterfly#3`
  > The middle of a glacier rope team is the most likely place for someone to fall into a crevasse, and the rope must hold that load while still letting the other team members anchor in. An alpine butterfly on each middle climber's harness g…

- _top result hit keywords: ['alpine butterfly', 'glacier']_

---

## ✓ [47/100] 'munter hitch belay no device'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *What it does* (hybrid=0.90, kw=1.00, vec=0.86) — `knots.munter-hitch#0`
  > The Munter hitch is a friction knot that provides belay and rappel functionality using only a carabiner — no belay device required. Essential as a backup when a climber drops or breaks their belay device, when rescue improvisation requir…

**2.** `knots` · *Strengths* (hybrid=0.78, kw=0.90, vec=0.73) — `knots.munter-hitch#3`
  > - Works with any locking carabiner (pear-shaped is best for smooth feeding). - No belay device to lose, drop, or break. - Universally available — every climber carries lockers. - Provides strong friction — can hold any climber. - Doubles…

**3.** `knots` · *When to use it* (hybrid=0.76, kw=0.82, vec=0.73) — `knots.munter-hitch#5`
  > - Belay device dropped or broken mid-route. - Lowering an injured climber when a different rope setup is needed. - Improvised rappel descent without a device. - Self-rescue scenarios. - As a primary belay choice when traveling ultralight…

- _top result hit keywords: ['munter', 'friction']_

---

## ✓ [48/100] 'italian hitch climbing'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *The Italian alternative name* (hybrid=0.87, kw=1.00, vec=0.81) — `knots.munter-hitch#7`
  > In Europe, this knot is universally called the "Italian hitch" — same knot, same use. American climbers and Anglophone climbers call it the Munter (after Werner Munter, the Swiss mountain guide who popularized it). The terminology doesn'…

**2.** `knots` · *What it does* (hybrid=0.79, kw=0.81, vec=0.78) — `knots.munter-hitch#0`
  > The Munter hitch is a friction knot that provides belay and rappel functionality using only a carabiner — no belay device required. Essential as a backup when a climber drops or breaks their belay device, when rescue improvisation requir…

**3.** `knots` · *Practice before it matters* (hybrid=0.72, kw=0.72, vec=0.72) — `knots.munter-hitch#6`
  > Tie and use the Munter on a low-angle slab or close to the ground, repeatedly, before you need it on a real route. The flipping action is unintuitive; muscle memory matters when adrenaline is involved. Pair the Munter with a "mule hitch"…

- _top result hit keywords: ['munter', 'italian']_

---

## ✓ [49/100] 'klemheist friction hitch webbing'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Klemheist* (hybrid=0.87, kw=1.00, vec=0.81) — `knots.klemheist-and-autoblock#1`
  > **How to tie**: take a short loop of cord (or webbing — Klemheist works on webbing where Prusik struggles). Hold the loop along the climbing rope. Wrap the loop tightly around the climbing rope, going UP — 4–6 wraps. Pass the bottom of t…

**2.** `knots` · *What friction hitches do* (hybrid=0.79, kw=0.76, vec=0.80) — `knots.klemheist-and-autoblock#0`
  > Friction hitches grip the climbing rope when loaded and slide easily when unloaded. They're used for: rappel backups (the "third hand"), ascending a fixed rope, escaping a belay system, hauling, and rescue improvisation. The Prusik is th…

**3.** `knots` · *Cautions* (hybrid=0.75, kw=0.69, vec=0.78) — `knots.klemheist-and-autoblock#6`
  > Friction hitches generate heat under load — a Prusik or Klemheist holding a fall on a thin rope can melt the cord. They're not designed to catch leader falls. Use them within their design purpose. Inspect cords regularly for glazing (shi…

- _top result hit keywords: ['klemheist', 'friction', 'ascending']_

---

## ✓ [50/100] 'autoblock rappel backup third hand'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Rappel backup setup* (hybrid=0.82, kw=0.77, vec=0.83) — `knots.klemheist-and-autoblock#5`
  > 1. Set up your rappel device. 2. Below the device, on your leg loop or belay loop, clip an autoblock loop around both rappel strands. 3. The autoblock should grip when slid up against the rappel device, slide down with the rope when you …

**2.** `knots` · *What friction hitches do* (hybrid=0.78, kw=1.00, vec=0.69) — `knots.klemheist-and-autoblock#0`
  > Friction hitches grip the climbing rope when loaded and slide easily when unloaded. They're used for: rappel backups (the "third hand"), ascending a fixed rope, escaping a belay system, hauling, and rescue improvisation. The Prusik is th…

**3.** `knots` · *Autoblock (French Prusik)* (hybrid=0.77, kw=0.86, vec=0.73) — `knots.klemheist-and-autoblock#2`
  > **How to tie**: take a short loop of cord. Wrap the loop around the climbing rope 4–6 times — wraps lie next to each other, not on top of each other. Clip both ends of the loop into a single locking carabiner on your harness.  **Properti…

- _top result hit keywords: ['autoblock', 'rappel', 'backup']_

---

## ✓ [51/100] 'water knot webbing sling tie'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Sling sizing for climbing* (hybrid=0.90, kw=1.00, vec=0.86) — `knots.water-knot#2`
  > A 24-inch sling (single-length) and 48-inch sling (double-length) are climbing standards. To tie one: cut webbing to length + 12 inches for the knot, tie a water knot, leave 3" tails, you've got your sling. Sewn slings (Bluewater, Mammut…

**2.** `knots` · *What it does* (hybrid=0.90, kw=0.83, vec=0.93) — `knots.water-knot#0`
  > The water knot (also called ring bend, tape knot) joins two ends of webbing (flat tubular or flat solid) to create a sling. It's the standard knot for tying anchor slings, equalizing webbing between fixed points, making personal slings f…

**3.** `knots` · *How to tie it* (hybrid=0.86, kw=0.79, vec=0.89) — `knots.water-knot#1`
  > 1. Tie a loose overhand knot in one end of the webbing — single half-knot, leaving a long tail. 2. Take the other end of the webbing and trace back through the overhand knot, following the exact path of the first end in reverse. The two …

- _top result hit keywords: ['water knot', 'webbing']_

---

## ✓ [52/100] 'EDK flat overhand rappel rope join'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *What it does* (hybrid=0.89, kw=1.00, vec=0.84) — `knots.edk-rappel-joining#0`
  > The flat overhand bend joins two ropes for rappelling. It's controversial — sometimes called the European Death Knot (EDK) — but when tied correctly it's a fast, low-profile knot that pulls cleanly when retrieving the rope. The reason it…

**2.** `knots` · *Alternative: double overhand* (hybrid=0.87, kw=0.96, vec=0.83) — `knots.edk-rappel-joining#6`
  > Tie a double overhand bend instead of single — two passes through the overhand, doubled strands. This is sometimes called the "Stein knot" or "double EDK." More secure than the single, slightly bulkier. Some climbers consider this the pr…

**3.** `knots` · *When to use the EDK* (hybrid=0.85, kw=0.95, vec=0.81) — `knots.edk-rappel-joining#3`
  > **Yes**: joining rappel ropes for a multi-pitch descent. The flat profile is the main advantage.  **No**: joining ropes for climbing belay (use a double fisherman). No: joining slings or webbing (use water knot for webbing). No: any appl…

- _top result hit keywords: ['EDK', 'flat overhand', 'rappel']_

---

## ✓ [53/100] 'double fisherman join climbing rope'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Alternative: double fisherman* (hybrid=0.94, kw=1.00, vec=0.91) — `knots.edk-rappel-joining#5`
  > The double fisherman (see knots.double-fisherman) is the most secure rope-joining knot but is much harder to untie after loading and can snag badly during rope retrieval on rock features. Some climbers use double fisherman for any joinin…

**2.** `knots` · *What it does* (hybrid=0.91, kw=0.96, vec=0.89) — `knots.double-fisherman#0`
  > The double fisherman joins two ropes of equal diameter (or close) end-to-end with very high strength and a low chance of slipping. It's the standard knot for joining ropes for rappels, for creating Prusik loops, and for tying loop slings…

**3.** `knots` · *When to use the EDK* (hybrid=0.89, kw=1.00, vec=0.85) — `knots.edk-rappel-joining#3`
  > **Yes**: joining rappel ropes for a multi-pitch descent. The flat profile is the main advantage.  **No**: joining ropes for climbing belay (use a double fisherman). No: joining slings or webbing (use water knot for webbing). No: any appl…

- _top result hit keywords: ['double fisherman', 'joining']_

---

## ✓ [54/100] 'bowline on a bight two loops'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Use as a two-point anchor* (hybrid=0.89, kw=0.99, vec=0.85) — `knots.bowline-on-a-bight#4`
  > A bowline on a bight tied between two equalized anchor points gives you two clip-in loops at the master point. The two loops can be clipped together or separately depending on need. Easier to untie than equivalent figure-eight setups.

**2.** `knots` · *What it does* (hybrid=0.87, kw=0.94, vec=0.84) — `knots.bowline-on-a-bight#0`
  > The bowline on a bight creates two parallel loops in the middle of a rope, without using the ends. Used for: rescue rigging (one loop under each arm of a patient lifted vertically, or one loop for each leg in an improvised harness), maki…

**3.** `knots` · *Strength and reliability* (hybrid=0.86, kw=0.90, vec=0.85) — `knots.bowline-on-a-bight#5`
  > Bowline on a bight retains good rope strength (60–70% range). Like all bowlines, it can shake loose under cyclic loading if not backed up — add a barrel knot (double overhand) on each leg of the loop as a backup if the application warran…

- _top result hit keywords: ['bowline', 'bight', 'two loops']_

---

## ✓ [55/100] 'prusik ascending climbing rope'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Climbing the rope on Klemheist + Prusik* (hybrid=0.90, kw=1.00, vec=0.86) — `knots.klemheist-and-autoblock#7`
  > Field improvisation for ascending a fixed rope: tie a Klemheist around the rope with a long loop of cord — stand in this. Tie a Prusik above the Klemheist, clip to your harness with a sling. To climb: lift the Klemheist (foot loop) by sl…

**2.** `knots` · *Overview* (hybrid=0.88, kw=0.91, vec=0.86) — `knots.prusik#0`
  > The prusik is a friction hitch — a small loop of thinner cord tied around a thicker rope. When weighted, it grips the main rope. When unweighted, it slides freely. The prusik is the foundational tool for ascending a rope, self-rescue, ha…

**3.** `knots` · *Common uses* (hybrid=0.86, kw=0.93, vec=0.83) — `knots.prusik#4`
  > - **Ascending a rope** in self-rescue (foot prusik + waist prusik, alternating) - **Self-belay** while rappelling (a prusik above your descender catches a fall) - **Hauling** an injured climber or pulling tension on a guyline - **Crevass…

- _top result hit keywords: ['prusik', 'ascend']_

---

## ◐ [56/100] 'seizure friend on ground'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *If one approaches* (hybrid=0.73, kw=1.00, vec=0.61) — `wildlife.alligators-and-crocodiles#3`
  > Back away slowly and steadily. Never turn your back. Distance is your friend; an alligator is unlikely to chase you 30 yards across dry ground if you keep moving. Get to high ground or behind cover. If an alligator hisses at you or moves…

**2.** `first-aid` · *In the backcountry* (hybrid=0.72, kw=0.46, vec=0.83) — `first-aid.seizure#5`
  > Even a "routine" seizure in someone with known epilepsy is a backcountry emergency if you're far from care. The person may not be able to safely continue the trip; they may be at risk of a second seizure; they may have injured themselves…

**3.** `first-aid` · *When to call for emergency* (hybrid=0.71, kw=0.57, vec=0.77) — `first-aid.seizure#4`
  > Call 911 / PLB / satellite SOS if: - Seizure lasts longer than 5 minutes (status epilepticus — medical emergency). - Person doesn't wake up after the seizure ends. - Another seizure follows immediately. - Seizure happened in water. - Per…

- _right domain but #2, not top_
- _no expected topic keywords found in top result: ['seizure', 'side', 'time']_

---

## ✗ [57/100] 'epileptic fit what to do'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `gear-fixes` · *Overview* (hybrid=0.73, kw=1.00, vec=0.62) — `gear-fixes.repair-kit#0`
  > The right small repair kit fits in a sandwich-sized bag and lets you fix 90% of common gear failures. Build one once, refresh it after every trip.

**2.** `trip-basics` · *During the trip* (hybrid=0.71, kw=0.97, vec=0.59) — `trip-basics.conditioning#3`
  > First 2–3 days are the hardest while your body adjusts. Don't plan the most ambitious mileage early. Drink and eat more than feels necessary; deficit catches up. Sleep is part of fitness; don't skimp on rest. If something hurts persisten…

**3.** `navigation` · *Naismith's Rule (and improvements)* (hybrid=0.68, kw=0.99, vec=0.55) — `navigation.pace-and-time#0`
  > Naismith's classic rule for hiking time: 1 hour per 3 miles (5 km) of horizontal distance, plus 1 hour per 2,000 feet (600 m) of elevation gain. For most fit hikers with a moderate pack, this is too fast; Tranter's correction adjusts for…

- _domain: top3 = ['gear-fixes', 'trip-basics', 'navigation'], expected 'first-aid'_
- _no expected topic keywords found in top result: ['seizure', 'side position', 'time']_

---

## ✓ [58/100] 'chest pain elderly hiker'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Heart attack — recognize it* (hybrid=0.86, kw=1.00, vec=0.80) — `first-aid.heart-attack-stroke#1`
  > **Common signs**: chest pain or pressure (often described as "elephant on my chest," sometimes burning or squeezing), pain radiating to jaw, neck, shoulder, or arm (usually left). Shortness of breath, nausea, sweating, lightheadedness, s…

**2.** `trip-basics` · *Special populations* (hybrid=0.58, kw=0.22, vec=0.74) — `trip-basics.conditioning#5`
  > Older hikers: conditioning matters more, not less; older bodies recover more slowly from training so start earlier. Heavier hikers: pack weight is harder on joints; consider lighter gear and shorter days. Hikers with chronic conditions (…

**3.** `wildlife` · *Treatment* (hybrid=0.58, kw=0.52, vec=0.60) — `wildlife.bark-scorpion#5`
  > Wash the sting area. Cool compress for pain. For mild cases in healthy adults: rest, OTC pain reliever per label, monitor. Evacuate to medical care for: any child under 6 with sting symptoms, any sting with rapid onset of severe systemic…

- _top result hit keywords: ['heart attack']_

---

## ✓ [59/100] 'stroke FAST test face arm speech'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Stroke — recognize with FAST* (hybrid=0.82, kw=1.00, vec=0.74) — `first-aid.heart-attack-stroke#3`
  > **F — Face**: ask the person to smile. Is one side drooping? **A — Arms**: ask them to raise both arms. Does one drift down or stay weak? **S — Speech**: ask them to repeat a simple sentence. Is it slurred or confused? **T — Time**: note…

**2.** `first-aid` · *Heat exhaustion vs heat stroke* (hybrid=0.52, kw=0.27, vec=0.63) — `first-aid.heat-illness#0`
  > Heat exhaustion: heavy sweating, cool/clammy skin, weakness, nausea, headache, fast weak pulse, normal or mildly elevated core temperature. The person is conscious and usually still sweating. Heat stroke is a medical emergency: core temp…

**3.** `first-aid` · *Heart attack — recognize it* (hybrid=0.52, kw=0.30, vec=0.61) — `first-aid.heart-attack-stroke#1`
  > **Common signs**: chest pain or pressure (often described as "elephant on my chest," sometimes burning or squeezing), pain radiating to jaw, neck, shoulder, or arm (usually left). Shortness of breath, nausea, sweating, lightheadedness, s…

- _top result hit keywords: ['stroke', 'FAST', 'time']_

---

## ✓ [60/100] 'diabetic low blood sugar'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Two kinds, both dangerous* (hybrid=0.83, kw=1.00, vec=0.76) — `first-aid.diabetic-emergency#0`
  > **Hypoglycemia (low blood sugar)** is far more common and develops fast — minutes. **Hyperglycemia (high blood sugar)** develops over hours to days and can progress to diabetic ketoacidosis (DKA). Both can be fatal if untreated. Field-tr…

**2.** `first-aid` · *Recognize hyperglycemia / DKA* (hybrid=0.65, kw=0.52, vec=0.71) — `first-aid.diabetic-emergency#3`
  > Develops over hours to days: - Excessive thirst, frequent urination - Fatigue, weakness - Nausea, vomiting - Abdominal pain - Deep rapid breathing ("Kussmaul respiration") - Fruity / acetone breath odor - Confusion progressing to coma - …

**3.** `first-aid` · *Treat hypoglycemia* (hybrid=0.53, kw=0.11, vec=0.70) — `first-aid.diabetic-emergency#2`
  > If conscious and able to swallow safely: - 15g fast-acting carbohydrate: 4 glucose tablets, half a regular soda (NOT diet), 4 ounces of juice, 1 tablespoon honey, 1 tube glucose gel. - Wait 15 minutes, reassess. - If still symptomatic, r…

- _top result hit keywords: ['hypoglycemia']_

---

## ✓ [61/100] 'diabetic coma emergency'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Recognize hyperglycemia / DKA* (hybrid=0.85, kw=1.00, vec=0.79) — `first-aid.diabetic-emergency#3`
  > Develops over hours to days: - Excessive thirst, frequent urination - Fatigue, weakness - Nausea, vomiting - Abdominal pain - Deep rapid breathing ("Kussmaul respiration") - Fruity / acetone breath odor - Confusion progressing to coma - …

**2.** `first-aid` · *Treat hypoglycemia* (hybrid=0.71, kw=0.54, vec=0.78) — `first-aid.diabetic-emergency#2`
  > If conscious and able to swallow safely: - 15g fast-acting carbohydrate: 4 glucose tablets, half a regular soda (NOT diet), 4 ounces of juice, 1 tablespoon honey, 1 tube glucose gel. - Wait 15 minutes, reassess. - If still symptomatic, r…

**3.** `first-aid` · *Recognize hypoglycemia* (hybrid=0.64, kw=0.38, vec=0.76) — `first-aid.diabetic-emergency#1`
  > Sudden onset over 15–30 minutes: - Shakiness, sweating, pale clammy skin - Confusion, irritability, anxiety - Hunger - Weakness, dizziness - Rapid pulse, palpitations - Slurred speech, uncoordinated movement (looks like intoxication) - S…

- _top result hit keywords: ['hyperglycemia', 'DKA', 'evacuate']_

---

## ✓ [62/100] 'asthma attack inhaler'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Pre-trip planning for known asthma* (hybrid=0.89, kw=1.00, vec=0.84) — `first-aid.asthma-attack#6`
  > Anyone with known asthma should: - Carry rescue inhaler AND a spare. Don't go into the backcountry with one inhaler; they fail. - Carry their preventer/controller inhaler too — daily use, not for attacks. - Pre-medicate before known trig…

**2.** `first-aid` · *When to evacuate immediately* (hybrid=0.85, kw=0.92, vec=0.82) — `first-aid.asthma-attack#4`
  > - Severe attack signs above (silent chest, can't speak full sentences, blue lips). - Rescue inhaler not relieving symptoms. - Attack continues or worsens after 15–30 minutes of treatment. - Severe agitation or sudden quietness in the pat…

**3.** `first-aid` · *Treat with their rescue inhaler* (hybrid=0.83, kw=0.86, vec=0.82) — `first-aid.asthma-attack#2`
  > The standard rescue inhaler is albuterol (Ventolin, ProAir) — a blue inhaler. Standard dose for an attack: 2 puffs, wait 60 seconds, 2 more puffs. Use a spacer if they have one (improves drug delivery). Wait 5–10 minutes; if symptoms imp…

- _top result hit keywords: ['inhaler', 'attack']_

---

## ✓ [63/100] 'wheezing breathing trouble'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Recognize it* (hybrid=0.86, kw=1.00, vec=0.79) — `first-aid.asthma-attack#0`
  > Asthma attack signs: wheezing on exhale (or both directions in severe attacks), shortness of breath, tight chest, persistent cough that won't quit, difficulty speaking in full sentences. Severe attack: silent chest (so little air moving …

**2.** `first-aid` · *Recognize it fast* (hybrid=0.69, kw=0.78, vec=0.65) — `first-aid.anaphylaxis#0`
  > Anaphylaxis is a whole-body allergic reaction that can kill in minutes. Common triggers in the outdoors: bee/wasp stings, food (peanuts, tree nuts, shellfish), medications, latex. Signs come on within seconds to 30 minutes of exposure: w…

**3.** `first-aid` · *After they revive* (hybrid=0.67, kw=0.66, vec=0.68) — `first-aid.drowning#3`
  > Anyone who lost consciousness, inhaled water, or required CPR must be evacuated to medical care, even if they seem completely fine afterward. "Secondary drowning" — fluid in the lungs causing breathing trouble — can develop hours later. …

- _top result hit keywords: ['asthma']_

---

## ✓ [64/100] 'trench foot wet feet cold'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Foot care discipline* (hybrid=0.89, kw=1.00, vec=0.85) — `first-aid.trench-foot#5`
  > Look at your feet at the end of every wet day. Pale, mottled, numb feet warrant immediate attention even if you "feel fine." Wash feet at camp if water allows, dry thoroughly, sleep in dry socks. Trench foot is far easier to prevent than…

**2.** `first-aid` · *In rain pants and gaiters* (hybrid=0.87, kw=0.92, vec=0.84) — `first-aid.trench-foot#6`
  > Constant moisture from inside (sweat) is also a trench foot risk. On long wet days, boots fill with sweat even from "dry" feet, especially in cooler weather where evaporation is low. Stop, remove boots, wring out socks, air feet for 10 m…

**3.** `first-aid` · *What it is* (hybrid=0.83, kw=0.66, vec=0.90) — `first-aid.trench-foot#0`
  > Trench foot — formally "immersion foot" — is tissue damage from prolonged exposure to wet, cool conditions, even above freezing. Hours to days of wet feet at temperatures from about 30°F to 60°F can damage skin, nerves, and small blood v…

- _top result hit keywords: ['trench foot', 'dry socks']_

---

## ✓ [65/100] 'feet pale numb after wet hike'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Foot care discipline* (hybrid=0.89, kw=0.95, vec=0.86) — `first-aid.trench-foot#5`
  > Look at your feet at the end of every wet day. Pale, mottled, numb feet warrant immediate attention even if you "feel fine." Wash feet at camp if water allows, dry thoroughly, sleep in dry socks. Trench foot is far easier to prevent than…

**2.** `first-aid` · *Symptoms* (hybrid=0.86, kw=1.00, vec=0.81) — `first-aid.trench-foot#1`
  > Early stages: numbness and tingling in feet, skin pale or blotchy, "pins and needles" sensation. Feet feel cold or numb even when warmed. Progressive stages: feet become red, swollen, painful when warmed (intense throbbing). Skin becomes…

**3.** `first-aid` · *Prevention is most of the answer* (hybrid=0.70, kw=0.49, vec=0.78) — `first-aid.trench-foot#4`
  > - **Dry feet are everything**. Change socks midday if wet from stream crossings, sweat, or rain — even just 30 minutes of dry-out helps. - **Carry 2–3 pairs of hiking socks** on multi-day trips. - **Wool or wool-blend socks** retain insu…

- _top result hit keywords: ['trench foot', 'dry']_

---

## ✓ [66/100] 'struck by lightning CPR'

**Safety:** intent=`cpr_resuscitation` · mode=`locked_procedure` · risk=`high`

**1.** `first-aid` · *Priority: check breathing and pulse* (hybrid=0.85, kw=0.86, vec=0.85) — `first-aid.lightning-strike-injury#2`
  > Most lightning strike deaths occur from cardiac arrest in the seconds after the strike. CPR can be life-saving. With multiple victims, "reverse triage" applies: in a normal mass-casualty scenario, you prioritize victims showing signs of …

**2.** `first-aid` · *What lightning does to a person* (hybrid=0.85, kw=1.00, vec=0.78) — `first-aid.lightning-strike-injury#0`
  > Lightning can injure through five mechanisms: direct strike (rare, often lethal), side flash (current jumps from a nearby struck object to a person), ground current (the most common — current spreads through the ground and across the bod…

**3.** `first-aid` · *Lightning-strike seizures* (hybrid=0.83, kw=0.78, vec=0.85) — `first-aid.seizure#6`
  > Lightning strike victims sometimes have seizures from cardiac or neurological injury. Treat the same way (protect, time, side position), but lightning is also a CPR-priority indication if the heart has stopped. Multiple injuries are comm…

- _top result hit keywords: ['lightning', 'reverse triage', 'CPR']_

---

## ✓ [67/100] 'sucking chest wound seal'

**Safety:** intent=`first_aid` · mode=`locked_procedure` · risk=`high`

**1.** `first-aid` · *Sucking chest wound* (hybrid=0.88, kw=1.00, vec=0.82) — `first-aid.chest-and-abdominal-wounds#1`
  > **Recognition**: a hole in the chest wall (front, side, or back of torso between collarbone and last rib) that bubbles, hisses, or "sucks" with breathing. May make a slurping or whistling sound on inhale or exhale. The patient often has …

**2.** `first-aid` · *Why these are different* (hybrid=0.68, kw=0.69, vec=0.68) — `first-aid.chest-and-abdominal-wounds#0`
  > Penetrating injuries to the chest or abdomen can cause life-threatening internal damage with little outward bleeding. Standard "direct pressure" can be inappropriate (pushing on a chest wound can collapse a lung; pushing on exposed bowel…

**3.** `first-aid` · *Outdoor mechanisms of penetrating trauma* (hybrid=0.68, kw=0.77, vec=0.64) — `first-aid.chest-and-abdominal-wounds#6`
  > - Falling on a stick or ski pole — common with downhill mountaineers. - Sharp branch piercing during a fall through brush. - Rockfall driving rocks into the body. - Hunting accidents (gunshot, arrow). - Knife slips during food prep or wo…

- _top result hit keywords: ['chest seal', 'three sides', 'pneumothorax']_

---

## ◐ [68/100] 'abdomen wound bowel exposed'

**Safety:** intent=`first_aid` · mode=`locked_procedure` · risk=`high`

**1.** `first-aid` · *Why these are different* (hybrid=0.83, kw=1.00, vec=0.76) — `first-aid.chest-and-abdominal-wounds#0`
  > Penetrating injuries to the chest or abdomen can cause life-threatening internal damage with little outward bleeding. Standard "direct pressure" can be inappropriate (pushing on a chest wound can collapse a lung; pushing on exposed bowel…

**2.** `first-aid` · *Abdominal wounds* (hybrid=0.76, kw=0.75, vec=0.77) — `first-aid.chest-and-abdominal-wounds#2`
  > **Recognition**: a wound to the belly (any depth) — knife, branch, gunshot, severe blunt trauma. Signs of serious abdominal injury: visible exit of internal contents (bowel, mesentery, blood), severe pain that worsens, rigid tender abdom…

**3.** `first-aid` · *Cleaning a minor wound* (hybrid=0.53, kw=0.10, vec=0.72) — `first-aid.wound-care#0`
  > Once bleeding is controlled, the most important thing for non-life-threatening wounds is thorough cleaning. Flush with clean drinkable water under pressure — a squeeze of water from a bag punctured with a pinhole, or a syringe if you car…

- _no expected topic keywords found in top result: ['abdominal', 'moist dressing', 'do not push']_

---

## ✓ [69/100] 'object impaled in body'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Penetrating object still in place* (hybrid=0.89, kw=1.00, vec=0.84) — `first-aid.chest-and-abdominal-wounds#3`
  > **Do not remove** any object impaled in the body. The object may be compressing a blood vessel or organ; pulling it out can release a fatal bleed. Stabilize the object so it doesn't move (cone of cloth or padding around it, taped in plac…

**2.** `first-aid` · *What lightning does to a person* (hybrid=0.61, kw=0.34, vec=0.72) — `first-aid.lightning-strike-injury#0`
  > Lightning can injure through five mechanisms: direct strike (rare, often lethal), side flash (current jumps from a nearby struck object to a person), ground current (the most common — current spreads through the ground and across the bod…

**3.** `first-aid` · *Blunt impact / penetrating injury* (hybrid=0.59, kw=0.20, vec=0.76) — `first-aid.eye-injuries#3`
  > A blow to the eye (rock fall, branch, falling gear) needs medical evaluation if there's bleeding inside the eye (visible blood in the colored part), changes in vision, severe pain, or sudden flashes or floaters. For penetrating injuries …

- _top result hit keywords: ['stabilize', 'do not remove', 'impaled']_

---

## ✓ [70/100] 'anaphylaxis epi pen leg'

**Safety:** intent=`first_aid` · mode=`locked_procedure` · risk=`high`

**1.** `first-aid` · *Use epinephrine immediately if available* (hybrid=0.85, kw=0.98, vec=0.80) — `first-aid.anaphylaxis#1`
  > If the person has a prescribed epinephrine auto-injector (EpiPen, Auvi-Q, generic), help them use it without delay. Inject into the outer thigh muscle, through clothing if necessary. Hold in place for the time the device specifies (usual…

**2.** `first-aid` · *Anaphylaxis (severe allergic reaction)* (hybrid=0.83, kw=1.00, vec=0.76) — `first-aid.bites-stings#3`
  > Symptoms include rapid swelling of the face/lips/tongue/throat, difficulty breathing, wheezing, hives spreading rapidly, dizziness, vomiting, or loss of consciousness. This is a life-threatening emergency. If the person has a prescribed …

**3.** `first-aid` · *Position and protect* (hybrid=0.79, kw=0.99, vec=0.70) — `first-aid.anaphylaxis#2`
  > After epinephrine: lay the person flat with legs elevated about 12 inches, unless they are vomiting (then on their side) or having difficulty breathing (then sitting up is fine, do not force flat). Loosen tight clothing. Do not give them…

- _top result hit keywords: ['epinephrine', 'thigh']_

---

## ✓ [71/100] 'scorpion stung kid Arizona'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *The only medically dangerous US scorpion* (hybrid=0.90, kw=1.00, vec=0.86) — `wildlife.bark-scorpion#0`
  > Out of roughly 90 scorpion species in the US, the Arizona bark scorpion is the only one whose sting routinely causes severe systemic symptoms in healthy adults and is occasionally fatal. Range: Arizona (especially central and southern), …

**2.** `wildlife` · *Children and severe cases* (hybrid=0.78, kw=0.79, vec=0.78) — `wildlife.bark-scorpion#4`
  > Children under 6 are at much higher risk for severe systemic symptoms. A bark scorpion sting on a small child can be a true emergency. Symptoms in kids: sudden inability to sit still, abnormal eye movements, drooling, sometimes vomiting,…

**3.** `wildlife` · *US scorpions* (hybrid=0.75, kw=0.52, vec=0.85) — `wildlife.spiders-and-scorpions#1`
  > The vast majority of US scorpions are not medically dangerous — painful sting like a wasp, no lasting harm. The exception: the Arizona bark scorpion (Centruroides sculpturatus) in the desert Southwest. Yellowish-brown, slender, about 3 i…

- _top result hit keywords: ['bark scorpion']_

---

## ✓ [72/100] 'child seized after lightning'

**Safety:** intent=`lightning_storm` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `first-aid` · *Causes outdoors* (hybrid=0.79, kw=1.00, vec=0.69) — `first-aid.seizure#1`
  > Causes a person to seize in the backcountry: known epilepsy with missed medications (most common), severe head injury, hypoglycemia in a diabetic, severe electrolyte imbalance (dehydration, hyponatremia), heat stroke at extreme temperatu…

**2.** `first-aid` · *Evacuate every strike victim* (hybrid=0.66, kw=0.55, vec=0.71) — `first-aid.lightning-strike-injury#6`
  > Even lightning victims who feel fine after a strike need hospital evaluation. Cardiac complications can develop hours later. Internal burns may not be visible. Neurological damage may show up gradually. Activate emergency response, docum…

**3.** `weather` · *After a strike* (hybrid=0.66, kw=0.51, vec=0.72) — `weather.lightning-safety#3`
  > A lightning strike victim is safe to touch — they don't carry residual charge. Begin CPR immediately if there's no pulse or no breathing; lightning often stops heart and breathing without other damage, and victims can be revived. Treat b…

- _top result hit keywords: ['seizure', 'lightning']_

---

## ✓ [73/100] 'snake bit hand swelling'

**Safety:** intent=`animal_encounter` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `wildlife` · *If bitten* (hybrid=0.84, kw=0.75, vec=0.88) — `wildlife.snakes#3`
  > Move calmly away from the snake to avoid a second bite. Sit or lie down with the bitten area at or below heart level. Remove rings, watches, and tight clothing on the affected limb before swelling sets in. Mark the leading edge of swelli…

**2.** `first-aid` · *Snake bites* (hybrid=0.82, kw=0.73, vec=0.85) — `first-aid.bites-stings#0`
  > Move away from the snake — do not try to catch or kill it. A clear description of color and pattern is helpful for medical staff; a phone photo from a safe distance is even better. Keep the person calm and as still as possible; immobiliz…

**3.** `wildlife` · *Avoiding bites* (hybrid=0.79, kw=1.00, vec=0.69) — `wildlife.rattlesnakes#3`
  > Watch where you put your hands and feet. Wear sturdy boots and long pants in rattlesnake country. Tap brushy ground ahead with a trekking pole. Avoid walking at night in summer in dry country without a light. Don't step over logs without…

- _top result hit keywords: ['snake']_

---

## ✗ [74/100] 'ate a mushroom feeling fine but worried'

> _Some unknown-mushroom queries should refuse; but 'fell sick after mushroom' should hit death cap / amanita warnings._

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Symptoms* (hybrid=0.76, kw=0.71, vec=0.79) — `plants.death-camas#3`
  > Nausea, vomiting, abdominal pain within 1–3 hours of eating. Salivation, weakness, dizziness, slow heart rate, low blood pressure. Severe cases progress to coma and death from cardiovascular collapse. Symptoms can be delayed up to 8 hour…

**2.** `water` · *Overview* (hybrid=0.72, kw=1.00, vec=0.60) — `water.unsafe-water-sources#0`
  > In the backcountry, treat **all** water from natural sources as potentially contaminated until purified — even fast-moving, clear-looking water at high elevation. Pathogens to worry about include *Giardia*, *Cryptosporidium*, *E. coli*, …

**3.** `plants` · *Amatoxin poisoning timeline* (hybrid=0.70, kw=0.64, vec=0.72) — `plants.wild-mushrooms#3`
  > Death cap and related species contain amatoxins. Symptoms come in stages: 6–24 hours after eating, sudden severe vomiting and watery diarrhea (often mistaken for food poisoning). 24–72 hours, apparent recovery — patient feels better — to…

- _intent: got 'general', expected 'plant_id_edibility'_

---

## ◐ [75/100] 'wife is acting confused at altitude'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Recognize hypoglycemia* (hybrid=0.72, kw=1.00, vec=0.60) — `first-aid.diabetic-emergency#1`
  > Sudden onset over 15–30 minutes: - Shakiness, sweating, pale clammy skin - Confusion, irritability, anxiety - Hunger - Weakness, dizziness - Rapid pulse, palpitations - Slurred speech, uncoordinated movement (looks like intoxication) - S…

**2.** `water` · *Recognizing it* (hybrid=0.69, kw=0.80, vec=0.65) — `water.dehydration#0`
  > Early signs: thirst, dark yellow or amber urine, dry mouth, headache, irritability, fatigue. Moderate: dizziness on standing, infrequent urination (more than 4 hours between bathroom stops in active heat), dry skin that doesn't bounce ba…

**3.** `first-aid` · *High Altitude Cerebral Edema (HACE)* (hybrid=0.65, kw=0.70, vec=0.62) — `first-aid.altitude-illness#1`
  > HACE is a life-threatening progression of AMS — swelling of the brain. Signs: ataxia (unable to walk a straight line, heel-to-toe test fails), confusion, irrational behavior, severe headache that doesn't respond to rest. HACE can kill wi…

- _no expected topic keywords found in top result: ['HACE', 'altitude', 'descend']_

---

## ✓ [76/100] 'rappelling joined ropes loose'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *When to use the EDK* (hybrid=0.84, kw=1.00, vec=0.77) — `knots.edk-rappel-joining#3`
  > **Yes**: joining rappel ropes for a multi-pitch descent. The flat profile is the main advantage.  **No**: joining ropes for climbing belay (use a double fisherman). No: joining slings or webbing (use water knot for webbing). No: any appl…

**2.** `knots` · *What it does* (hybrid=0.82, kw=0.91, vec=0.78) — `knots.edk-rappel-joining#0`
  > The flat overhand bend joins two ropes for rappelling. It's controversial — sometimes called the European Death Knot (EDK) — but when tied correctly it's a fast, low-profile knot that pulls cleanly when retrieving the rope. The reason it…

**3.** `knots` · *Inspecting before rappel* (hybrid=0.79, kw=0.68, vec=0.83) — `knots.edk-rappel-joining#7`
  > Always check the knot before clipping into the rappel rope: - Both strands lie flat through the knot. - No crossing strands. - 12"+ tails. - Knot is tight, no slack between strands. - Same knot type at both ends if you tied a backup.  So…

- _top result hit keywords: ['EDK', 'double fisherman']_

---

## ✓ [77/100] 'climbing partner needs belay'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *When to use it* (hybrid=0.86, kw=1.00, vec=0.80) — `knots.munter-hitch#5`
  > - Belay device dropped or broken mid-route. - Lowering an injured climber when a different rope setup is needed. - Improvised rappel descent without a device. - Self-rescue scenarios. - As a primary belay choice when traveling ultralight…

**2.** `knots` · *What it does* (hybrid=0.78, kw=0.86, vec=0.75) — `knots.munter-hitch#0`
  > The Munter hitch is a friction knot that provides belay and rappel functionality using only a carabiner — no belay device required. Essential as a backup when a climber drops or breaks their belay device, when rescue improvisation requir…

**3.** `knots` · *Strengths* (hybrid=0.76, kw=0.65, vec=0.81) — `knots.munter-hitch#3`
  > - Works with any locking carabiner (pear-shaped is best for smooth feeding). - No belay device to lose, drop, or break. - Universally available — every climber carries lockers. - Provides strong friction — can hold any climber. - Doubles…

- _top result hit keywords: ['belay']_

---

## ✓ [78/100] 'what hitch should I use to rappel safely'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *What friction hitches do* (hybrid=0.85, kw=1.00, vec=0.78) — `knots.klemheist-and-autoblock#0`
  > Friction hitches grip the climbing rope when loaded and slide easily when unloaded. They're used for: rappel backups (the "third hand"), ascending a fixed rope, escaping a belay system, hauling, and rescue improvisation. The Prusik is th…

**2.** `knots` · *What it does* (hybrid=0.83, kw=0.96, vec=0.78) — `knots.munter-hitch#0`
  > The Munter hitch is a friction knot that provides belay and rappel functionality using only a carabiner — no belay device required. Essential as a backup when a climber drops or breaks their belay device, when rescue improvisation requir…

**3.** `knots` · *When to use it* (hybrid=0.78, kw=0.93, vec=0.72) — `knots.munter-hitch#5`
  > - Belay device dropped or broken mid-route. - Lowering an injured climber when a different rope setup is needed. - Improvised rappel descent without a device. - Self-rescue scenarios. - As a primary belay choice when traveling ultralight…

- _top result hit keywords: ['autoblock', 'prusik', 'backup']_

---

## ✓ [79/100] 'tiny brown spider violin Missouri'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Identification* (hybrid=0.85, kw=0.88, vec=0.84) — `wildlife.brown-recluse#1`
  > Small spider, body 1/4 to 1/2 inch long, leg span up to 1.5 inches. Tan to dark brown, sometimes pale yellow-tan. The diagnostic feature is the violin-shaped marking on the back (cephalothorax), with the violin's "neck" pointing toward t…

**2.** `wildlife` · *Medically significant US spiders* (hybrid=0.82, kw=1.00, vec=0.75) — `wildlife.spiders-and-scorpions#0`
  > **Black widow** (Latrodectus species) — shiny black with red hourglass on the underside of the abdomen, common across the lower 48. Bite causes severe muscle cramps, especially in the abdomen, sometimes mistaken for appendicitis. Sweatin…

**3.** `wildlife` · *Range — narrower than you'd think* (hybrid=0.70, kw=0.76, vec=0.67) — `wildlife.brown-recluse#0`
  > Brown recluse populations are firmly established in the central south and central midwest US: Arkansas, Missouri, Kansas, Oklahoma, eastern Texas, southern Indiana, Illinois, Kentucky, Tennessee, Mississippi, Alabama, and adjacent states…

- _top result hit keywords: ['violin']_

---

## ✓ [80/100] 'shiny black spider red hourglass'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Identification* (hybrid=0.79, kw=1.00, vec=0.70) — `wildlife.black-widow#1`
  > Adult female (the dangerous one): shiny black body about 1/2 inch long, with a bright red hourglass marking on the underside of the abdomen. Body globular and shiny. Legs long, slender, black. Males are much smaller, brown-tan, and harml…

**2.** `wildlife` · *Medically significant US spiders* (hybrid=0.74, kw=0.84, vec=0.70) — `wildlife.spiders-and-scorpions#0`
  > **Black widow** (Latrodectus species) — shiny black with red hourglass on the underside of the abdomen, common across the lower 48. Bite causes severe muscle cramps, especially in the abdomen, sometimes mistaken for appendicitis. Sweatin…

**3.** `wildlife` · *Identification (North America)* (hybrid=0.57, kw=0.42, vec=0.64) — `wildlife.snakes#1`
  > The four medically significant venomous snake families in the U.S.: rattlesnakes (multiple species, rattle on tail, broad triangular head, distinct pit between eye and nostril), copperheads (eastern U.S., copper-bronze color, hourglass c…

- _top result hit keywords: ['hourglass']_

---

## ✓ [81/100] 'wading scared of stingrays'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Avoiding stingrays — the shuffle* (hybrid=0.80, kw=0.72, vec=0.83) — `wildlife.jellyfish-and-stings#5`
  > Shuffle your feet when wading in shallow sandy water. This pushes stingrays out of the sand before you step on them. Don't step down; slide forward. This single technique prevents almost all stingray injuries to swimmers and waders.

**2.** `trip-basics` · *Why crossings are dangerous* (hybrid=0.75, kw=1.00, vec=0.64) — `trip-basics.river-crossings#0`
  > Moving water is far stronger than its surface suggests. Water knee-deep at 5 mph exerts about 65 pounds of force on your shins; at thigh-deep it's enough to sweep most adults off their feet. Cold water (most mountain streams) shuts down …

**3.** `trip-basics` · *Scout the crossing* (hybrid=0.69, kw=0.84, vec=0.63) — `trip-basics.river-crossings#1`
  > Walk 50–100 meters up and downstream looking for the best line. Best is usually: wide and shallow (flow spreads out and slows), gravel-bed (firmer footing than mud or moss-covered rocks), no log jams or strainers downstream (those drown …

- _top result hit keywords: ['stingray', 'shuffle', 'sand']_

---

## ✗ [82/100] 'fern-like skin pattern after thunder'

**Safety:** intent=`lightning_storm` · mode=`rag_with_safety_appendix` · risk=`medium`

**1.** `plants` · *Long-term sun sensitivity* (hybrid=0.76, kw=0.98, vec=0.67) — `plants.wild-parsnip#4`
  > Even after the initial blisters heal, the affected skin remains hyper-sensitive to sunburn for months. The healed pattern can re-darken with sun exposure. Cover affected areas with sunscreen and clothing for at least one full summer afte…

**2.** `weather` · *When you're at risk* (hybrid=0.76, kw=1.00, vec=0.66) — `weather.lightning-safety#0`
  > "If you can hear thunder, lightning is close enough to strike you." That single rule covers most decisions. The "30-30 rule" formalizes it: when the time between a flash and its thunder is 30 seconds or less, the storm is within 6 miles …

**3.** `plants` · *Why it makes you react* (hybrid=0.75, kw=0.90, vec=0.69) — `plants.poison-ivy-oak-sumac#1`
  > All three plants contain urushiol, an oily resin that triggers a delayed allergic reaction in roughly 85% of people. Reactions appear 12–72 hours after exposure as itchy red streaks, bumps, and oozing blisters in the pattern of contact. …

- _domain: top3 = ['plants', 'weather', 'plants'], expected 'first-aid'_
- _no expected topic keywords found in top result: ['lightning', 'Lichtenberg', 'evacuate']_

---

## ✓ [83/100] 'asthma attack at altitude cold air'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Exercise-induced asthma* (hybrid=0.88, kw=1.00, vec=0.82) — `first-aid.asthma-attack#7`
  > Many people have asthma only triggered by exercise — they don't have an attack at rest but get one with sustained exertion. Strategies: warm up gradually for 10–15 minutes, breathe through the nose or a buff (warms air), avoid cold-air s…

**2.** `first-aid` · *Pre-trip planning for known asthma* (hybrid=0.85, kw=0.97, vec=0.80) — `first-aid.asthma-attack#6`
  > Anyone with known asthma should: - Carry rescue inhaler AND a spare. Don't go into the backcountry with one inhaler; they fail. - Carry their preventer/controller inhaler too — daily use, not for attacks. - Pre-medicate before known trig…

**3.** `first-aid` · *Triggers in the outdoors* (hybrid=0.85, kw=0.87, vec=0.84) — `first-aid.asthma-attack#1`
  > Common backcountry asthma triggers: cold dry air (winter, high altitude), exercise (especially without warm-up), pollen and mold (spring/fall in forests), smoke from forest fires (huge concern in dry seasons in the western US), wildfire …

- _top result hit keywords: ['asthma', 'cold', 'inhaler']_

---

## ✓ [84/100] 'lyme rash bullseye treatment'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *When to see a doctor* (hybrid=0.91, kw=1.00, vec=0.88) — `wildlife.ticks-disease-vectors#4`
  > Bullseye rash (expanding red ring with clearer center) is a classic Lyme sign — see a doctor immediately, often within 2–4 weeks of bite. Any of these symptoms in the weeks after a tick bite: unexplained fever, fatigue, joint pain, muscl…

**2.** `first-aid` · *When to see a doctor* (hybrid=0.80, kw=0.80, vec=0.80) — `first-aid.tick-removal#5`
  > Seek medical evaluation if you develop any of these in the 30 days after a tick bite: - A rash, especially the classic "bullseye" of Lyme disease (a red ring expanding outward from the bite over days) - Fever, chills, body aches, fatigue…

**3.** `wildlife` · *The bite and what follows* (hybrid=0.60, kw=0.19, vec=0.78) — `wildlife.brown-recluse#3`
  > The bite itself often goes unnoticed — many victims don't recall being bitten. Over the next hours: mild stinging, then increasing pain, redness, and swelling. Within 1–2 days, a classic "bullseye" lesion can develop: pale center surroun…

- _top result hit keywords: ['tick', 'lyme', 'bullseye', 'antibiotic']_

---

## ✓ [85/100] 'splints for diabetic in shock'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Field treatment* (hybrid=0.79, kw=1.00, vec=0.70) — `first-aid.shock#2`
  > Treat the cause if you can — control bleeding, splint major fractures, treat anaphylaxis with epinephrine, give cool water for heat exhaustion. Lay the person flat, on their back, on an insulating pad off cold ground. Elevate legs about …

**2.** `first-aid` · *Treat secondary injuries* (hybrid=0.76, kw=0.95, vec=0.68) — `first-aid.lightning-strike-injury#5`
  > After airway/breathing/circulation are managed: control bleeding, splint broken bones, cover burns with sterile dressings, treat for shock (cover, keep warm). Suspect spinal injury for any thrown victim and stabilize the head/neck.

**3.** `first-aid` · *Evacuation* (hybrid=0.75, kw=0.79, vec=0.73) — `first-aid.spinal-injury#4`
  > This is a high-priority evacuation: PLB, satellite SOS, calling 911. Stay with the patient. Treat for shock (cover with insulation, keep warm). Monitor breathing. Splint any obvious limb injuries without moving the spine. Receiving medic…

- _top result hit keywords: ['shock']_

---

## ✓ [86/100] 'datura'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Recreational use is a major hazard* (hybrid=0.83, kw=1.00, vec=0.75) — `plants.datura#4`
  > Datura is sometimes sought out for hallucinogenic effects. Internet folklore suggests "safe doses" — none exist. The toxic concentration varies wildly between plants, parts of the same plant, and even season. Hospital-documented deaths a…

**2.** `plants` · *Why it kills* (hybrid=0.81, kw=1.00, vec=0.73) — `plants.datura#0`
  > Datura contains tropane alkaloids (atropine, scopolamine, hyoscyamine) that affect the nervous system and heart. People are poisoned three ways: eating berries or seeds (kids find them attractive), brewing tea or smoking dried plant mate…

**3.** `plants` · *Don't grow it as ornamental* (hybrid=0.76, kw=0.82, vec=0.74) — `plants.datura#5`
  > Some Datura species (like Angel's Trumpet, Brugmansia, which is related) are sold as garden plants because of their dramatic flowers. They are equally toxic. Children eating the seeds is a recurring poisoning pattern. If you have small c…

- _top result hit keywords: ['datura']_

---

## ✓ [87/100] 'hemlock'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Symptoms of poisoning* (hybrid=0.84, kw=1.00, vec=0.77) — `plants.poison-hemlock#3`
  > Hemlock poisoning starts within 15 minutes to 2 hours: nausea, vomiting, abdominal pain, dilated pupils, weakness, slow heart rate, paralysis starting in the legs and ascending. Water hemlock can also cause violent seizures. Death is fro…

**2.** `plants` · *Why these matter* (hybrid=0.80, kw=0.99, vec=0.72) — `plants.poison-hemlock#0`
  > Poison hemlock (Conium maculatum) and water hemlock (Cicuta species) are among the deadliest plants in North America. Water hemlock is sometimes called "the most violently toxic plant in North America" — a small bite of root can kill an …

**3.** `plants` · *What to do if exposure suspected* (hybrid=0.79, kw=0.84, vec=0.76) — `plants.poison-hemlock#5`
  > If a person ate any portion of a suspected hemlock or its look-alikes, evacuate immediately to medical care. Do not induce vomiting unless instructed by Poison Control (1-800-222-1222 in the US). Bring the plant — root, stem, leaves, flo…

- _top result hit keywords: ['hemlock']_

---

## ◐ [88/100] 'foxglove'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `plants` · *Common confusions* (hybrid=0.84, kw=1.00, vec=0.77) — `plants.foxglove#3`
  > Foxglove leaves are sometimes mistaken for comfrey, especially before flowering. Comfrey leaves are also fuzzy and gray-green. Comfrey has been used in herbal medicine; people brewing "comfrey tea" from misidentified foxglove leaves have…

**2.** `plants` · *Avoiding it* (hybrid=0.78, kw=0.84, vec=0.75) — `plants.foxglove#5`
  > Don't plant foxglove if you have small children. Teach kids never to eat any garden flower. In the wild, admire the spectacular flower spikes from a distance and do not pick them — sap on hands can transfer to food. Many foragers who use…

**3.** `plants` · *Why it matters* (hybrid=0.72, kw=0.67, vec=0.74) — `plants.foxglove#0`
  > Foxglove contains digitalis glycosides — the same compounds used as a heart medication, with a vanishingly small margin between therapeutic and lethal. Eating even small amounts of leaves, flowers, or seeds can stop the heart. It's a str…

- _no expected topic keywords found in top result: ['digitalis', 'cardiac']_

---

## ✓ [89/100] 'rattler'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Range and species* (hybrid=0.79, kw=1.00, vec=0.69) — `wildlife.rattlesnakes#0`
  > Rattlesnakes (genera Crotalus and Sistrurus) inhabit every state in the lower 48 except Maine, Delaware, and possibly Rhode Island, plus parts of southern Canada and most of Mexico. The most clinically significant species: - **Western di…

**2.** `wildlife` · *How rattlesnakes hunt and react* (hybrid=0.51, kw=0.00, vec=0.73) — `wildlife.rattlesnakes#1`
  > Rattlesnakes are pit vipers — they detect heat and prey with infrared pits between eye and nostril. They ambush, striking when warmth-emitting prey passes close. Toward humans, they prefer to avoid — most rattlesnake encounters end with …

**3.** `wildlife` · *When and where bites happen* (hybrid=0.51, kw=0.00, vec=0.72) — `wildlife.rattlesnakes#2`
  > Most rattlesnake bites in the US happen in summer, in the South and Southwest, on the hands and feet of people who deliberately interacted with the snake (handling, photographing closely, or trying to kill it) or who stepped without look…

- _top result hit keywords: ['rattlesnake']_

---

## ✓ [90/100] 'cottonmouth'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *Distinguishing from harmless water snakes* (hybrid=0.80, kw=1.00, vec=0.72) — `wildlife.cottonmouth#2`
  > Many harmless water snakes share their habitat and get killed by people misidentifying them. Key differences: - **Cottonmouth swims with body partly out of water** (buoyant due to lung position); harmless water snakes (Nerodia species) s…

**2.** `wildlife` · *Range and habitat* (hybrid=0.77, kw=0.71, vec=0.80) — `wildlife.cottonmouth#0`
  > The cottonmouth is the only venomous water snake in the US, ranging across the southeastern coastal plain from Virginia through Florida and west to eastern Texas, plus the Mississippi River valley up to southern Illinois. They live in sl…

**3.** `wildlife` · *Behavior* (hybrid=0.74, kw=0.65, vec=0.78) — `wildlife.cottonmouth#3`
  > Cottonmouths have a reputation for aggression that's somewhat exaggerated — they prefer to display threats (open mouth, vibrating tail) rather than strike. But they're more willing to stand their ground than most US snakes, and they're f…

- _top result hit keywords: ['cottonmouth']_

---

## ✓ [91/100] 'elk rut'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *In rut, in town* (hybrid=0.87, kw=1.00, vec=0.81) — `wildlife.elk#3`
  > Estes Park, Banff, Jasper, and similar towns have habituated elk that lounge on lawns and golf courses. Don't take selfies. Don't walk between a bull and his cows. Don't approach calves. Bulls have attacked people in their yards, charged…

**2.** `wildlife` · *Elk charges* (hybrid=0.83, kw=0.94, vec=0.78) — `wildlife.elk#4`
  > Same general response as bison: get behind solid cover, run perpendicular to the charge line not straight away, climb if needed (large tree, vehicle, structure). Elk are slightly less massive than bison but have antlers (bulls) and clove…

**3.** `wildlife` · *Range and habitat* (hybrid=0.82, kw=0.99, vec=0.74) — `wildlife.elk#0`
  > Wild elk in the Rocky Mountains (CO, WY, MT, ID, NM), Pacific Northwest (WA, OR), parts of California, Arizona, Utah, and reintroduced populations in PA, KY, NC, VA, AR, TN, MI, WI. Bulls are 700–1,000 pounds with massive antlers (in rut…

- _top result hit keywords: ['elk', 'rut']_

---

## ✓ [92/100] 'bison'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `wildlife` · *In a vehicle* (hybrid=0.86, kw=0.96, vec=0.82) — `wildlife.bison#5`
  > Bison on roads in Yellowstone is a daily traffic phenomenon. Stay in your vehicle. Drive slowly past — if the herd is on the road, wait it out; don't push through. Don't honk to clear them; agitated bison can charge a vehicle (and someti…

**2.** `wildlife` · *Calves and protective cows* (hybrid=0.84, kw=1.00, vec=0.77) — `wildlife.bison#6`
  > Late spring through summer, cow bison are highly protective of calves. Walking between a cow and a calf will trigger a charge. Hikers crossing meadows with scattered bison need to know whether calves are present and route widely around a…

**3.** `wildlife` · *If gored* (hybrid=0.84, kw=0.96, vec=0.79) — `wildlife.bison#4`
  > Bison gore with their horns and toss victims with their massive heads. Injuries are often severe: deep punctures, broken ribs, internal organ damage, spinal injuries. The bison usually moves on after the initial attack but may circle bac…

- _top result hit keywords: ['bison', 'Yellowstone']_

---

## ✓ [93/100] 'alpine butterfly'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *How to tie it (twist method)* (hybrid=0.84, kw=0.95, vec=0.79) — `knots.alpine-butterfly#1`
  > 1. Hold the rope horizontally with both hands, about 18 inches apart. 2. Take the section between your hands and twist it twice — same direction both twists — to form a figure-eight shape with two loops side by side. 3. Pull the upper lo…

**2.** `knots` · *What it does* (hybrid=0.83, kw=0.93, vec=0.79) — `knots.alpine-butterfly#0`
  > The alpine butterfly creates a strong, secure loop in the middle of a rope without using the ends. It's the standard knot for the middle climber on a glacier rope team, for isolating a damaged section of rope, for clipping to a fixed poi…

**3.** `knots` · *Strength and reliability* (hybrid=0.82, kw=0.97, vec=0.76) — `knots.alpine-butterfly#5`
  > The alpine butterfly retains about 60–70% of rope strength, comparable to most other climbing knots (knots universally weaken ropes; this is expected). It's symmetric — loads from both ends behave identically. It doesn't capsize or roll.…

- _top result hit keywords: ['alpine', 'butterfly']_

---

## ✓ [94/100] 'EDK'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Alternative: double overhand* (hybrid=0.73, kw=1.00, vec=0.61) — `knots.edk-rappel-joining#6`
  > Tie a double overhand bend instead of single — two passes through the overhand, doubled strands. This is sometimes called the "Stein knot" or "double EDK." More secure than the single, slightly bulkier. Some climbers consider this the pr…

**2.** `knots` · *What it does* (hybrid=0.68, kw=0.79, vec=0.63) — `knots.edk-rappel-joining#0`
  > The flat overhand bend joins two ropes for rappelling. It's controversial — sometimes called the European Death Knot (EDK) — but when tied correctly it's a fast, low-profile knot that pulls cleanly when retrieving the rope. The reason it…

**3.** `knots` · *How to tie it correctly* (hybrid=0.59, kw=0.64, vec=0.57) — `knots.edk-rappel-joining#1`
  > 1. Lay the two rope ends side by side, both pointing in the same direction. 2. Tie a single overhand knot with the doubled rope. Both strands lie parallel through the knot. 3. Leave at least 12 inches of tail on each end. 4. Dress the kn…

- _top result hit keywords: ['EDK']_

---

## ✓ [95/100] 'autoblock'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Rappel backup setup* (hybrid=0.82, kw=1.00, vec=0.74) — `knots.klemheist-and-autoblock#5`
  > 1. Set up your rappel device. 2. Below the device, on your leg loop or belay loop, clip an autoblock loop around both rappel strands. 3. The autoblock should grip when slid up against the rappel device, slide down with the rope when you …

**2.** `knots` · *When to use which* (hybrid=0.67, kw=0.70, vec=0.66) — `knots.klemheist-and-autoblock#3`
  > **Prusik**: ascending a fixed rope, hauling, rescue rigging. Holds heavy loads. Hard to slide when unloaded — used for static work.  **Klemheist**: ascending on webbing, single-direction friction grab, lighter loads than Prusik. Easier t…

**3.** `knots` · *What friction hitches do* (hybrid=0.67, kw=0.74, vec=0.64) — `knots.klemheist-and-autoblock#0`
  > Friction hitches grip the climbing rope when loaded and slide easily when unloaded. They're used for: rappel backups (the "third hand"), ascending a fixed rope, escaping a belay system, hauling, and rescue improvisation. The Prusik is th…

- _top result hit keywords: ['autoblock', 'rappel']_

---

## ✓ [96/100] 'munter'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `knots` · *Practice before it matters* (hybrid=0.76, kw=0.95, vec=0.69) — `knots.munter-hitch#6`
  > Tie and use the Munter on a low-angle slab or close to the ground, repeatedly, before you need it on a real route. The flipping action is unintuitive; muscle memory matters when adrenaline is involved. Pair the Munter with a "mule hitch"…

**2.** `knots` · *The Italian alternative name* (hybrid=0.75, kw=1.00, vec=0.65) — `knots.munter-hitch#7`
  > In Europe, this knot is universally called the "Italian hitch" — same knot, same use. American climbers and Anglophone climbers call it the Munter (after Werner Munter, the Swiss mountain guide who popularized it). The terminology doesn'…

**3.** `knots` · *What it does* (hybrid=0.70, kw=0.71, vec=0.70) — `knots.munter-hitch#0`
  > The Munter hitch is a friction knot that provides belay and rappel functionality using only a carabiner — no belay device required. Essential as a backup when a climber drops or breaks their belay device, when rescue improvisation requir…

- _top result hit keywords: ['munter']_

---

## ✓ [97/100] 'seizur'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *When to call for emergency* (hybrid=0.66, kw=1.00, vec=0.52) — `first-aid.seizure#4`
  > Call 911 / PLB / satellite SOS if: - Seizure lasts longer than 5 minutes (status epilepticus — medical emergency). - Person doesn't wake up after the seizure ends. - Another seizure follows immediately. - Seizure happened in water. - Per…

**2.** `first-aid` · *Pre-trip planning for known epilepsy* (hybrid=0.58, kw=0.75, vec=0.51) — `first-aid.seizure#7`
  > Anyone with known epilepsy should: tell the group leader pre-trip; carry their medications double-bagged and well-distributed (so a lost pack doesn't end the trip); avoid known seizure triggers (sleep deprivation, alcohol, flashing light…

**3.** `first-aid` · *In the backcountry* (hybrid=0.57, kw=0.74, vec=0.51) — `first-aid.seizure#5`
  > Even a "routine" seizure in someone with known epilepsy is a backcountry emergency if you're far from care. The person may not be able to safely continue the trip; they may be at risk of a second seizure; they may have injured themselves…

- _top result hit keywords: ['seizure', 'time']_

---

## ✓ [98/100] 'diabetic'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Two kinds, both dangerous* (hybrid=0.82, kw=1.00, vec=0.74) — `first-aid.diabetic-emergency#0`
  > **Hypoglycemia (low blood sugar)** is far more common and develops fast — minutes. **Hyperglycemia (high blood sugar)** develops over hours to days and can progress to diabetic ketoacidosis (DKA). Both can be fatal if untreated. Field-tr…

**2.** `first-aid` · *Recognize hypoglycemia* (hybrid=0.75, kw=0.88, vec=0.69) — `first-aid.diabetic-emergency#1`
  > Sudden onset over 15–30 minutes: - Shakiness, sweating, pale clammy skin - Confusion, irritability, anxiety - Hunger - Weakness, dizziness - Rapid pulse, palpitations - Slurred speech, uncoordinated movement (looks like intoxication) - S…

**3.** `first-aid` · *Insulin pumps and altitude* (hybrid=0.69, kw=0.86, vec=0.62) — `first-aid.diabetic-emergency#6`
  > Insulin pumps can air-bubble at altitude as dissolved gas comes out of solution. Pre-trip, ask the manufacturer or your endocrinologist about how to handle altitude (Diabetes Camp protocols cover this; some pumps need priming/dis-priming…

- _top result hit keywords: ['hypoglycemia']_

---

## ✓ [99/100] 'trench foot'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *What it is* (hybrid=0.87, kw=1.00, vec=0.81) — `first-aid.trench-foot#0`
  > Trench foot — formally "immersion foot" — is tissue damage from prolonged exposure to wet, cool conditions, even above freezing. Hours to days of wet feet at temperatures from about 30°F to 60°F can damage skin, nerves, and small blood v…

**2.** `first-aid` · *When to evacuate* (hybrid=0.84, kw=0.94, vec=0.79) — `first-aid.trench-foot#3`
  > Severe trench foot, large areas of blistered or peeling skin, dark/blue tissue (deep injury), severe pain unrelieved by basic care, signs of infection. The patient may be unable to walk comfortably; evacuate by carrying or assisting. Tis…

**3.** `first-aid` · *Foot care discipline* (hybrid=0.84, kw=0.96, vec=0.79) — `first-aid.trench-foot#5`
  > Look at your feet at the end of every wet day. Pale, mottled, numb feet warrant immediate attention even if you "feel fine." Wash feet at camp if water allows, dry thoroughly, sleep in dry socks. Trench foot is far easier to prevent than…

- _top result hit keywords: ['immersion', 'wet']_

---

## ✓ [100/100] 'asthma'

**Safety:** intent=`general` · mode=`rag_freeform` · risk=`low`

**1.** `first-aid` · *Pre-trip planning for known asthma* (hybrid=0.84, kw=1.00, vec=0.77) — `first-aid.asthma-attack#6`
  > Anyone with known asthma should: - Carry rescue inhaler AND a spare. Don't go into the backcountry with one inhaler; they fail. - Carry their preventer/controller inhaler too — daily use, not for attacks. - Pre-medicate before known trig…

**2.** `first-aid` · *Exercise-induced asthma* (hybrid=0.82, kw=0.90, vec=0.78) — `first-aid.asthma-attack#7`
  > Many people have asthma only triggered by exercise — they don't have an attack at rest but get one with sustained exertion. Strategies: warm up gradually for 10–15 minutes, breathe through the nose or a buff (warms air), avoid cold-air s…

**3.** `first-aid` · *Triggers in the outdoors* (hybrid=0.80, kw=0.74, vec=0.82) — `first-aid.asthma-attack#1`
  > Common backcountry asthma triggers: cold dry air (winter, high altitude), exercise (especially without warm-up), pollen and mold (spring/fall in forests), smoke from forest fires (huge concern in dry seasons in the western US), wildfire …

- _top result hit keywords: ['inhaler', 'attack']_

---
