# Diagrammes UML - Plateforme Conversationnelle UWB

Voici les diagrammes UML basés sur la méthode du Processus Unifié (UP) décrite dans votre introduction. Vous pouvez inclure ces diagrammes dans le **Chapitre 3** de votre mémoire.

## 1. Diagramme des Cas d'Utilisation (Use Case Diagram)
Ce diagramme illustre les interactions entre les différents acteurs et le système.

```mermaid
usecaseDiagram
    actor "Étudiant" as etudiant
    actor "Personnel Administratif" as admin
    actor "Autorité Académique" as autorite
    
    package "Plateforme UWB" {
        usecase "S'authentifier" as UC_Auth
        usecase "Poser une question (Chatbot)" as UC_Chat
        usecase "Consulter les résultats/horaires" as UC_Consult
        usecase "Soumettre une demande (Attestation...)" as UC_Demande
        usecase "Gérer les demandes" as UC_Manage_Demandes
        usecase "Mettre à jour la base de connaissances" as UC_Update_KB
        usecase "Consulter le tableau de bord décisionnel" as UC_Dashboard
        usecase "Générer des indicateurs de performance" as UC_Stats
    }
    
    etudiant --> UC_Auth
    etudiant --> UC_Chat
    etudiant --> UC_Consult
    etudiant --> UC_Demande
    
    admin --> UC_Auth
    admin --> UC_Manage_Demandes
    admin --> UC_Update_KB
    
    autorite --> UC_Auth
    autorite --> UC_Dashboard
    autorite --> UC_Stats
    
    UC_Demande ..> UC_Auth : <<include>>
    UC_Chat ..> UC_Auth : <<include>>
    UC_Dashboard ..> UC_Auth : <<include>>
```

---

## 2. Diagramme de Classes (Class Diagram)
Ce diagramme modélise la structure de la base de données et l'architecture orientée objet du système.

```mermaid
classDiagram
    class Utilisateur {
        +UUID id
        +String nom
        +String email
        +String motDePasse
        +String role
        +seConnecter()
        +seDeconnecter()
    }
    
    class Etudiant {
        +String matricule
        +String promotion
        +String filiere
        +consulterNotes()
    }
    
    class Personnel {
        +String departement
        +String fonction
        +traiterDemande()
    }
    
    class RequeteChatbot {
        +UUID id
        +String contenuMessage
        +DateTime dateHeure
        +String intentionNLP
        +envoyerMistral()
    }
    
    class DemandeAdministrative {
        +UUID id
        +String typeDemande
        +String statut
        +DateTime dateSoumission
        +mettreAJourStatut()
    }
    
    class Document {
        +UUID id
        +String nomFichier
        +String urlSupabase
        +telecharger()
    }

    Utilisateur <|-- Etudiant
    Utilisateur <|-- Personnel
    Etudiant "1" -- "*" RequeteChatbot : "effectue"
    Etudiant "1" -- "*" DemandeAdministrative : "soumet"
    Personnel "1" -- "*" DemandeAdministrative : "traite"
    DemandeAdministrative "1" -- "*" Document : "contient"
```

---

## 3. Diagramme de Séquence : Interaction avec le Chatbot
Ce diagramme montre la chronologie des messages lors d'une interaction entre l'étudiant, l'application Flutter, la base de données (Supabase) et l'Intelligence Artificielle (Mistral).

```mermaid
sequenceDiagram
    actor E as Étudiant
    participant App as Application (Flutter)
    participant S as Base de Données (Supabase)
    participant M as IA (API Mistral)
    
    E->>App: Ouvre l'interface du Chatbot
    App->>S: Vérifie l'authentification (Token)
    S-->>App: Token valide
    E->>App: Saisit sa question ("Quand commence la session ?")
    App->>S: Enregistre la question dans l'historique
    App->>M: Envoie la question (Requête POST avec Contexte)
    activate M
    M-->>M: Analyse NLP & Génération de réponse
    M-->>App: Retourne la réponse générée
    deactivate M
    App->>S: Enregistre la réponse de l'IA
    App-->>E: Affiche la réponse à l'écran
```
