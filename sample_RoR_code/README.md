# sample_RoR_code
This project has code samples for a Job Matching Feature I developed from scratch.

Even though it is not a Ruby on Rails (RoR) project, I have structured the folders to match an RoR project and have included
the following types of files:

Models

Views (both user and admin)
Controllers (both user and admin)
Mailers
Specs (model tests and factories)
Database migrations
rake tasks
routes file

This project uses erb for the views, but I have worked on multiple projects that use haml.

The Job Matching feature allows users
- who are looking for people to fill job positions to create/edit/duplicate job postings, pay for job postings based on duration
(1, 2 or 3 months), track how many people expressed interest in their job postings and view the information provided by the people
who expressed interest in their job postings.
- who are looking for a job to view open job postings, search for job postings using various criteria, express interest in one or
more job postings and provide information to the potential employer
- with a role of admin to access financial and statistical reporting as well as limited editing capability of job postings

This feature also includes:
- scheduled rake tasks that notified users when their job postings were a week away from expiring and a second notification when
their job postings expired
- automatic email notifications


