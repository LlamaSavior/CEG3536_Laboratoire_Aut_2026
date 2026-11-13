# JOURNAL.md — Journal d'équipe, CEG 3536, laboratoire 1 (automne 2026)

Équipe : Dounia Bouimajdil et Nicolas Fredette — Section : A02 — Dépôt Git : https://github.com/LlamaSavior/CEG3536_Laboratoire_Aut_2026

## Jalon J1 (au plus tard le vendredi 25 septembre 2026, validé dans Git)

### Exigences de l'équipe
| Id | Exigence (reformulée par l'équipe) | Critère d'acceptation | Hypothèses |
|---|---|---|---|
| E1 |Programme en C|Le programme démarre correctement|Bonne intégration des laboratoires précédents |
| E2 |Appeler le cpde assembleur depuis le code en C |Les données transitent correctement |Les fonctions sont bien appelées |
| E3 | Convertir les données de vitesse|La vitesse calculée est précise |Le temps de mesure est 250ms |
| E4 |Lire le potentiomètre |Les valeurs sont lues et calculées correctement |Entrées PC0 et PC1|
| E5 |Contrôler la vitesse avec le potentiomètre |La vitesse va de 0 à 100% et ne change pas en arrêt ou urgence|Touch En ne contrôle plus lq vitesse|
| E6 |Lire lq température du capteur|Mesure proche de la réalité |Calibration du capteur |
| E7 |File pour les événements |Maximum de 32 et détéction si pleine |File indépendante de la carte |
| E8 |FSM en C |Les événements déclenchent les méchanismes correctes |Réutilisation du labo2 |
| E9 |Système d'arrêt d'urgence |Moteur s'arrête et reprend après l'acquitement | Réutilisation des laboratoires précédents|
| E10|Envoi des données assez rapide |Données envoyées toutes les 200ms |CSV |
| E11 | Tester sur Windows ou Linux|Le programme compile bien et les tests passent |GCC |
| E12 | Système robuste|Le système fonctionne bien même si plusieurs on entre plusieurs commandes en même temps |Vérification des erreurs |

### Rôles et rotation
| Séance | Réalise | Valide (essais, mesures, relecture) |
|---|---|---|
| Séance 0 | | |
| Séance 1 - 3 Novembre 2026 |Nicolas |Dounia |
| Séance 2 (démonstration) - 10 Novembre 2026 | Nicolas |Dounia |

### Échéancier des laboratoires 1 à 5
| Laboratoire | Séances | Démonstration | Remise | Responsable du suivi |
|---|---|---|---|---|
| 1 | | | 9 octobre 2026 | |
| 2 | | | | |
| 3 | 2| Faites en classe - vidéo sur GitHub | 16 Novembre 2020 | |
| 4 | | | | |
| 5 | | | | |

## Journal des séances

### Séance 0 — `<date>` — réalise : `<nom>` / valide : `<nom>`
- Objectifs :
- Fait :
- Décisions :
- Difficultés et solutions :
- Essais et mesures :
- Validations Git (auteur, message) :

### Séance 1 — `3 novembre 2026` — réalise : `Nicolas` / valide : `Dounia`
- Objectifs : Comprendre les consignes du labo et mettre en place les fichiers. Assignation des tâches et début du codage
- Fait : Tâches individuelles
- Décisions : Répartition du travail entre les 2 membres
- Difficultés et solutions : 
- Essais et mesures :
- Validations Git :

### Séance 2 — `10 novembre 2026` — réalise : `Nicolas` / valide : `Dounia`
- Objectifs : Démonstration à l'assistant d'enseignement
- Fait : Démonstration
- Décisions :
- Difficultés et solutions :
- Essais et mesures :
- Validations Git :

## Tableau des essais (T1 à T10)
| Essai | Date | Résultat observé | Verdict | Preuve (fichier) |
|---|---|---|---|---|
| T1 Initialisation en C | |Fonctionne | |main.c, fsm.c |
| T2 Appel d'assembleur par C| |Pas d'erreurs | |fichiers C |
| T3 Virgule fixe | | | | |
| T4 ADC et DMA | | | | |
| T5 Consigne | | | | |
| T6 Température | | | | |
| T7 File d'événements | | | | |
| T8 E-Stop | | | | |
| T9 Télémétrie | | | | |
| T10 Comparaison et trace | | | | |

## Routine conservée pour L3-A
- Routine : `button_pressed`, `led_set`, `motor_set_pwm`, `encoder_read`
- Interface :
- Cas d'essai :

## Déclaration des sources et de l'usage d'outils d'IA générative
- Sources : laboratoires précédents et fichiers sur Brightspace
- Outils d'IA (outil, version, usage) ou « aucun usage » : Utilisation pour une meilleure compréhension des consignes de laboratoire si nécéssaire et débogage
