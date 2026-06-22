# Modélisation du Système - Chatbot UWB (Université William Booth)

Ce document présente la modélisation technique et fonctionnelle du système de chatbot intelligent de l'UWB, intégrant l'IA Mistral et les services Firebase.

## 1. Architecture Globale (Diagramme de Composants)

L'architecture repose sur une application Flutter client qui orchestre les interactions entre l'utilisateur, la base de connaissances locale, Firebase pour les données persistantes, et l'API Mistral pour le traitement du langage naturel.

```mermaid
graph TD
    subgraph "Application Flutter (Client)"
        UI[Interface Utilisateur]
        CP[ChatProvider]
        MS[MistralService]
        FS[FirebaseService]
        KB_Assets[(Assets: Knowledge Base)]
    end

    subgraph "Services Cloud"
        Firebase_Auth[Firebase Auth]
        Firestore[Cloud Firestore]
        Mistral[API Mistral AI]
    end

    UI <--> CP
    CP <--> MS
    CP <--> FS
    
    MS -- "Lit (selon le rôle)" --> KB_Assets
    MS -- "Envoie Prompt + Contexte" --> Mistral
    
    FS -- "Authentification" --> Firebase_Auth
    FS -- "Profils & Historique" --> Firestore
```

## 2. Diagramme des Cas d'Utilisation

Ce diagramme identifie les principaux acteurs et leurs interactions avec le système.

```mermaid
usecaseDiagram
    actor "Étudiant" as etudiant
    actor "Agent Inscription" as agent
    actor "Rectorat / Décanat" as autorite
    
    package "Système Chatbot UWB" {
        usecase "S'authentifier" as UC_Auth
        usecase "Poser une question" as UC_Chat
        usecase "Consulter son profil" as UC_Profile
        usecase "Consulter l'historique des conversations" as UC_History
        usecase "Gérer la base de connaissances (Admin)" as UC_Admin_KB
    }
    
    etudiant --> UC_Auth
    etudiant --> UC_Chat
    etudiant --> UC_Profile
    
    agent --> UC_Auth
    agent --> UC_Chat
    agent --> UC_History
    
    autorite --> UC_Auth
    autorite --> UC_Chat
    autorite --> UC_History
```

## 3. Diagramme de Classes (Structure Logique)

Modélisation des services et des modèles de données principaux, montrant la séparation des responsabilités.

```mermaid
classDiagram
    class Etudiant {
        +String faculte
        +String promotion
        +String matricule
        +poserQuestion(message)
    }

    class Personnel {
        +String departement
        +String fonction
        +traiterDemande()
    }

    class UserProfile {
        +String id
        +String fullName
        +String email
        +String role
        +String faculte (Optionnel)
        +String promotion (Optionnel)
    }

    ChatProvider --> MistralService : "Utilise"
    ChatProvider --> FirebaseService : "Persiste via"
    MistralService ..> UserProfile : "Filtre par rôle"
    UserProfile <|-- Etudiant
    UserProfile <|-- Personnel
```

## 4. Diagramme de Séquence : Relation KB & Firebase

Ce diagramme illustre le flux critique où le rôle de l'utilisateur (stocké dans Firebase) définit le contexte de la base de connaissances (Knowledge Base) envoyé à l'IA.

```mermaid
sequenceDiagram
    actor U as Utilisateur
    participant App as Flutter (ChatProvider)
    participant FS as Firebase (Firestore)
    participant MS as MistralService
    participant KB as Assets (KB Files)
    participant AI as API Mistral

    U->>App: Remplit profil (Nom, Email, Faculté, Promotion)
    App->>FS: Enregistre profile (Rôle: étudiant/agent)
    FS-->>App: Confirmation
    
    U->>App: Envoie un message ("Quel sont les frais de ma faculté ?")
    App->>FS: Récupère le profil (Rôle, Faculté, Promotion)
    FS-->>App: Retourne le profil utilisateur
    
    App->>MS: sendMessage(message, rôle, faculté, promotion)
    
    alt Système non initialisé pour ce rôle/contexte
        MS->>KB: Lit les fichiers texte (assets/knowledge_base/[rôle]/)
        KB-->>MS: Renvoie le contenu (frais, procédures, etc.)
        MS-->>MS: Construit le System Prompt (Incorpore Faculté/Promotion)
    end
    
    MS->>AI: Envoie Prompt + Contexte KB + Historique
    AI-->>MS: Réponse générée
    
    MS-->>App: Retourne la réponse
    App->>FS: Sauvegarde la réponse dans l'historique
    App-->>U: Affiche la réponse
```

## 5. Relation Base de Connaissances - Firebase

| Composant | Rôle | Interaction |
| :--- | :--- | :--- |
| **Firebase (Firestore)** | **Source de Vérité Utilisateur** | Stocke le `role` de l'utilisateur (ex: 'etudiant', 'agent_inscription'). Ce rôle est la clé de filtrage. |
| **Knowledge Base (Assets)** | **Source de Vérité Académique** | Dossiers locaux contenant les documents officiels segmentés par dossiers nommés selon les rôles. |
| **Mistral Service** | **Médiateur Inteligent** | Utilise le `role` venant de Firebase pour charger dynamiquement les fichiers de la `Knowledge Base`. |

> **Note :** Cette architecture garantit que l'IA ne répond qu'avec des informations certifiées et pertinentes pour le rôle, la faculté et la promotion de l'utilisateur connecté via Firebase.

## 6. Synthèse des Flux (Input / Output)

### Inputs (Entrées)
- **Authentification** : Email, Mot de Passe.
- **Profil Étudiant** : Nom Complet, Rôle (Étudiant), **Faculté** (ex: Médecine, Polytechnique), **Promotion** (ex: L1, L2).
- **Requête** : Message texte saisi dans le chat.

### Outputs (Sorties)
- **Réponse IA** : Texte généré par Mistral filtré par le contexte académique (Knowledge Base) spécifique à la faculté/promotion.
- **Persistance** : Historique des messages sauvegardé dans Cloud Firestore.
- **Navigation** : Redirection vers le tableau de bord ou la vue profil.
