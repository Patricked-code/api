# VL, dividendes et séries base 100

## Point fondamental

Une VL simple et une VL ajustée dividendes ne racontent pas la même histoire.

Dans un fonds qui distribue ou détache des dividendes :

- la VL simple peut baisser mécaniquement au détachement ;
- la performance économique réelle de l'investisseur ne doit pas être lue uniquement sur cette VL simple ;
- une série ajustée dividendes est nécessaire pour représenter correctement la performance totale.

## Lecture recommandée des colonnes existantes

À partir du schéma actuel du projet :

- `value` : VL simple locale
- `value_USD` : VL simple en USD
- `value_EUR` : VL simple en EUR
- `dividende` : dividende local
- `dividende_USD` : dividende USD
- `dividende_EUR` : dividende EUR
- `vl_ajuste` : VL ajustée dividendes locale
- `vl_ajuste_USD` : VL ajustée dividendes USD
- `vl_ajuste_EUR` : VL ajustée dividendes EUR
- `base_100` : à documenter strictement comme une base 100 dérivée de la série économique retenue
- `base_100_InRef` : autre indice de référence ou série comparative, à clarifier dans le code métier

## Règle de représentation graphique recommandée

### Graphique 1 - VL publiée

Afficher la VL simple publiée pour la lecture réglementaire et documentaire.

### Graphique 2 - Performance totale

Afficher une série base 100 calculée à partir de la VL ajustée dividendes.

Cette série est celle qui traduit la performance économique réellement réinvestie.

## Recommandation de nomenclature cible

Pour professionnaliser la plateforme, il est recommandé d'aller vers une distinction explicite :

- `nav_published`
- `nav_total_return`
- `base_100_published`
- `base_100_total_return`

Autrement dit, si un `base 100 bis` existe fonctionnellement dans le projet, il doit être requalifié en série distincte et documentée, pas laissé implicite.

## Risque métier si on ne le fait pas

Sans séparation claire :

- les graphiques peuvent être trompeurs ;
- l'investisseur peut croire à une sous-performance lors d'un détachement de dividende ;
- les comparaisons inter-fonds deviennent incohérentes entre fonds de capitalisation et fonds de distribution.

## Conclusion

Pour ce projet OPCVM, la représentation professionnelle doit distinguer :

1. la VL publiée ;
2. la VL ajustée dividendes ;
3. la base 100 réglementaire ou simple si nécessaire ;
4. la base 100 de performance totale comme série principale de comparaison.
