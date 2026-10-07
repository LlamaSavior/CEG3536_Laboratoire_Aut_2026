# JOURNAL.md — Journal d'équipe, CEG 3536, laboratoire 1 (automne 2026)

Équipe : `Dounia Bouimajdil` et `Nicolas Fredette` — Section : `A02` — Dépôt Git : `CEG3536_Laboratoire_Aut_2026 > CEG3536_Lab1_Nicolas_Dounia`

## Jalon J1 (au plus tard le vendredi 25 septembre 2026, validé dans Git)

### Exigences de l'équipe
| Id | Exigence (reformulée par l'équipe) | Critère d'acceptation | Hypothèses |
|---|---|---|---|
| E1 |L'état initial est arrêt | au début, etat=arrêt et la DEL est rouge| la machine démarre sans interruption|
| E2 |A l'appui de User on a: arrêt, avant, arrêt, arriere, arrêt, ...|chaque appui change l'état  | anti-rebond|
| E3 |La couleur de la DEL indique l'état courant |une seule DEL allumée à la fois |table etat_vers_del correcte |
| E4 |Estop déclenche un arrêt d'urgence immédiat|l'isr met estop_flag à 1 | exit2 correcte|
| E5 |En arrêt d'urgence la DEL clignote à 2Hz |Alternance de rouge à éteinte |les fonctions de clignotement sont correctes|
| E6 |Pour passer de l'état d'urgence à l'arrêt il faut Touch et relacher Estop|en arrêt les boutons sont ignorés sauf les entrées valides|TouchPad et Estop fonctionnels |
| E7 |Hors urgence on a une extinction brève|touch_enabled est inversé et DEL éteinte pendant environ 100ms|TouchPad au labo4|
| E8 |code suit AAPCS et la structure|push et pop r4 et lr |tous les registres sauvegardé |
| E9 |jamais deux DEL allumées simultanément|vérifié par led_set et fsm_maj_del |led_set assure l'extinction des DEL non utilisées|

### Rôles et rotation
| Séance | Réalise | Valide (essais, mesures, relecture) |
|---|---|---|
| Séance 0 |Dounia Bouimajdil |Nicolas Fredette |
| Séance 1 |Nicolas Fredette |Dounia Bouimajdil |
| Séance 2 |Dounia Bouimajdil |Nicolas Fredette |

### Échéancier des laboratoires 1 à 5
| Laboratoire | Séances | Démonstration | Remise | Responsable du suivi |
|---|---|---|---|---|
| 1 |22.09.26 |29.09.26 | 9 octobre 2026 | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

## Journal des séances

### Séance 0 — `14.09.26` — réalise : `Dounia Bouimajdil` / valide : `Nicolas Fredette`
- Objectifs :
- Fait :
- Décisions :
- Difficultés et solutions :
- Essais et mesures :
- Validations Git (auteur, message) :

### Séance 1 — `22.09.26` — réalise : `Nicolas Fredette` / valide : `Dounia Bouimajdil`
- Objectifs : compléter button_pressed, estop, fsm_step
- Fait : implémentation des fonctions
- Décisions : centraliser les fonctions de DEL dans fsm_maj_del
- Difficultés et solutions : clignotement rapide alors ajustement du calcul entre clignotement et période scrutation
- Essais et mesures :
- Validations Git :

### Séance 2 — `29.09.26` — réalise : `Dounia Bouimajdil` / valide : `Nicolas Fredette`
- Objectifs : Faire la démonstration et fixer quelques bugs
- Fait : Démontrer devant l'AE
- Décisions :
- Difficultés et solutions : Implémenter tous les fonctions et trouver les erreurs avant la démonstration
- Essais et mesures : Un essai devant l'AE qui a été réussi
- Validations Git :

## Tableau des essais (T1 à T10)
| Essai | Date | Résultat observé | Verdict | Preuve (fichier) |
|---|---|---|---|---|
| T1 Réinitialisation |29.09.26 | au début, etat=arrêt et la DEL est rouge | réussie | |
| T2 Cycle User | 29.09.26 | rouge → verte → rouge → bleue → rouge | réussie | |
| T3 Anti-rebond | 29.09.26 | 1 seule transition pour l’appui maintenu | réussie | |
| T4 Niveaux logiques | 29.09.26 | Niveau actif consigné pour chaque bouton | réussie | |
| T5 E-Stop | 29.09.26 | Alternance de rouge à éteinte verte et bleu atteintes immédiatement | réussie | |
| T6 Clignotement | 29.09.26 | Elle clignotte | réussie | |
| T7 Acquittement | 29.09.26 | ne retourne pas quand E-stop est maintenu | réussie | |
| T8 User ignoré en urgence | 29.09.26 | user n'a aucun effet | réussie | |
| T9 Touch En hors urgence | 29.09.26 | extinction brève de la DEL active | réussie | |
| T10 Robustesse | 29.09.26 | on n'arrive pas à briser le système | réussie | |

## Routine conservée pour L3-A
- Routine : `button_pressed` ou `led_set`
- Interface :
- Cas d'essai :

## Déclaration des sources et de l'usage d'outils d'IA générative
- Sources :
- Outils d'IA (outil, version, usage) ou « aucun usage » :
