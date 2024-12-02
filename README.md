<!--
This source file is part of the Stanford Spezi Template Application open-source project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT
-->

# Spezi Template Application

[![Beta Deployment](https://github.com/StanfordSpezi/SpeziTemplateApplication/actions/workflows/beta-deployment.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziTemplateApplication/actions/workflows/beta-deployment.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziTemplateApplication/branch/main/graph/badge.svg?token=9fvSAiFJUY)](https://codecov.io/gh/StanfordSpezi/SpeziTemplateApplication)
[![DOI](https://zenodo.org/badge/589846478.svg)](https://zenodo.org/badge/latestdoi/589846478)

This repository contains the Spezi Template Application.  
It demonstrates using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Biodesign Digital Health Template Application](https://github.com/StanfordBDHG/TemplateApplication).

> **Note**  
> Do you want to try out the Spezi Template Application? You can download it to your iOS device using [TestFlight](https://testflight.apple.com/join/ipEezBY1)!

---

## Enhancements and Features Added

This fork of the Spezi Template Application introduces the following enhancements:

### **1. Health Data Check Task**
- A new task called `Health Data Check` has been added to the Scheduler.  
- **Purpose:** Encourages users to review their daily health metrics via the Health Dashboard.  
- **Integration:** Linked to the Health Dashboard for helpful insights, using Spezi's modular framework.  
- **Completion Tracking:** Task completion is persistently stored using `UserDefaults`, ensuring that task states are saved across sessions.

### **2. Interactive Task Flow**
- A redesigned **`EventView`** tracks task completion, providing clear feedback with a green checkmark and a "Task Completed" confirmation screen.  
- Tasks like `Health Data Check` dynamically navigate users to the **Health Dashboard** for interaction, returning to the completion screen afterward.

### **3. Enhanced Health Dashboard**
- The Health Dashboard displays **real-time metrics** such as:
  - Step count
  - Heart rate
  - Sleep hours
- Features include:
  - **Dynamic Visualization:** Charts for trends like step activity and sleep analysis.
  - **Manual Updates:** Users can manually adjust metrics with intuitive controls.
  - **Report Sharing:** Generates a detailed PDF health report for sharing.

### **4. State Persistence**
- Task completion states are managed using `UserDefaults`.  
- Ensures a consistent user experience by displaying the correct task status upon reopening the app.

---

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

This project is based on [ContinuousDelivery Example by Paul Schmiedmayer](https://github.com/PSchmiedmayer/ContinousDelivery) and the [Stanford Biodesign Digital Health Template Application](https://github.com/StanfordBDHG/TemplateApplication) provided using the MIT license.

---

## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
