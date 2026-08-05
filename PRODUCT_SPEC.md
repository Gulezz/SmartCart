# SmartCart — product specification

## Product promise

SmartCart helps a household eat according to its preferences and health goals
while minimising the trustworthy total cost of groceries and travel.

## Primary user story

As a user, I can write: “Ik ben veggie en wil graag een gezond weekmenu voor
twee personen.” SmartCart then:

1. creates a seven-day menu;
2. explains the nutritional balance without making medical claims;
3. consolidates all recipe ingredients and subtracts items already at home;
4. finds integrated nearby store branches;
5. matches every ingredient to actual products, prices and valid promotions;
6. evaluates buying everything in one store versus splitting over at most the
   user's chosen number of stores;
7. includes fuel/electricity, parking and route distance;
8. compares car, bike, e-bike and walking where feasible;
9. shows the route, store order, exact products and per-store subtotals.

## Inputs

### Household

- household size and servings;
- dietary preferences;
- allergies and hard exclusions;
- disliked ingredients;
- health goals;
- available cooking time;
- weekly budget;
- pantry items.

### Shopping constraints

- origin or current location;
- maximum radius;
- maximum number of stores;
- preferred chains or excluded stores;
- acceptable substitutions;
- promotion/loyalty-card eligibility.

### Transport

- car name and fuel type;
- consumption per 100 km or kWh per 100 km;
- current energy price;
- parking cost;
- bike/e-bike cargo capacity;
- optional time value and maximum trip duration.

## Optimisation objective

The current working engine minimises:

```text
total_cost = sum(selected_product_prices)
           + vehicle_energy_cost
           + parking_cost
```

Subject to:

- every required ingredient has an in-stock, non-expired offer;
- selected stores do not exceed `maxStores`;
- stores remain within `maxRadiusKm`;
- the plan respects cargo limits for non-car modes;
- dietary/allergy constraints have already filtered invalid products.

Future versions can add weighted time and carbon objectives. Keep money, time
and emissions visible separately so the user understands the trade-off.

## Health guardrails

- Allergies are hard constraints, not preferences.
- “Gezond” must be translated into explicit measurable guardrails with a
  qualified nutrition source or professional review.
- The system may provide general nutrition information, not diagnoses or
  treatment advice.
- Price optimisation may choose between nutritionally compatible products; it
  may not silently replace a product with an incompatible cheaper alternative.

## Price provenance states

| State | Meaning | UI behaviour |
|---|---|---|
| `verified` | Direct, current trusted feed | Normal price plus source |
| `recent` | Trusted feed within freshness window | Show check timestamp |
| `stale` | Outside freshness window | Warn; exclude when policy requires |
| `estimated` | Explicit model/derived estimate | Never present as exact |
| `unknown` | No usable price | Do not calculate false savings |

## Success measures

- percentage of requested ingredients with a recent verified match;
- median price-data age by retailer;
- realised savings versus the best complete single-store basket;
- percentage of plans changed because travel cost outweighed shelf savings;
- menu acceptance and edit rate;
- product substitution rejection rate;
- route completion rate;
- number of incorrect or expired promotion reports.

