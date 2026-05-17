# NPRT63

## NPRT63 - Project

[![Code License](https://img.shields.io/badge/Code%20License-GPLv2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Follow%20%40iammelvink-blue.svg?style=social&logo=linkedin)](https://www.linkedin.com/in/iammelvink)

## Overview
HydroAlert is a cross-platform application designed to bridge the communication gap between South African municipalities and their communities by providing timely water outage notifications and a structured platform for reporting water-related faults. Residents receive SMS alerts before planned outages, view area-specific schedules, and submit fault reports with photos and location details directly through the mobile app. Municipal administrators manage outage schedules and oversee fault reports through a desktop interface, while maintenance teams receive assigned tasks and update resolution progress in real time. IT staff monitor system performance, manage users, and handle bug reports to ensure the platform remains stable and reliable. Built with Flutter, FastAPI, and AWS, HydroAlert replaces the fragmented, unreliable communication methods currently used by municipalities with a single, organised, and accountable system.


This is the codebase produced for the Project course

Written in **Flutter and Python**

1. Methodologies/Project Management:

   - Agile

2. Coding Practices:

   - OOP (Object Oriented Programming)
   - MVC (Model View Controller)

3. Programming Languages/Frameworks:

   - Flutter (Dart)
   - Python

## Instructions

1. Make sure you have these installed

2. Clone `ONLY THE LATEST COMMIT` of this repository into your local machine using the terminal (mac) or
   [Gitbash (PC)](https://git-scm.com/download/win 'Gitbash (PC)') `to save storage space`

   ```sh
   git clone https://github.com/iammelvink/NPRT63.git --depth=1
   ```
## Backend Setup

### Prerequisites
- Python 3.11+
- pip

### Steps

1. Navigate to the backend directory
```sh
   cd NPRT63/backend
```

2. Create a virtual environment
```sh
   python -m venv venv
```

3. Activate the virtual environment

   **Linux/Mac:**
```sh
   source venv/bin/activate
```

   **Windows:**
```sh
   venv\Scripts\activate
```

4. Install dependencies
```sh
   pip install -r requirements.txt
```

5. Run the backend
```sh
   python -m uvicorn main:app --reload
```

6. Open your browser and go to `http://127.0.0.1:8000/docs` to view the API documentation

## Author(s)

- TLOTLISO LEDWABA - 202428830 (GROUP LEADER)
- TLOTLO NALEDI - 202422544
- TSEKI LEBOHANG TSEKI - 202434749
- MERCY MOTHATA - 202419335 


#### Lecturer: Melvin Kisten

[Melvin Kisten](https://github.com/iammelvink 'Melvin Kisten\'s GitHub page')

GitHub: @"Group members"
- [Tlotliso Ledwaba](https://github.com/Di-exGeneral)
- [Mercy Mothata](https://github.com/cipherMuse22)

LinkedIn: [Melvin Kisten](https://www.linkedin.com/in/iammelvink 'Melvin Kisten\'s LinkedIn page')

## Acknowledgments

To my lecturer [Melvin Kisten](https://www.linkedin.com/in/iammelvink 'Melvin Kisten\'s LinkedIn page') for their guidance

## More Stuff

Check out some other stuff on
[Melvin Kisten](https://github.com/iammelvink 'Melvin Kisten\'s GitHub page')
