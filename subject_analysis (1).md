# Subject Analysis — Room Booking Database

---

## 1. Candidate Subjects

### Entities and Key Attributes

#### Building
| Attribute | Type | Notes |
|---|---|---|
| `building_id` | PK | Primary key |
| `name` | NOT NULL | Building name |
| `address` | NOT NULL | Physical address |

#### Room
| Attribute | Type | Notes |
|---|---|---|
| `room_id` | PK | Primary key |
| `building_id` | FK | → Building |
| `name_or_number` | NOT NULL | Room identifier within the building |
| `capacity` | NOT NULL | Maximum number of people |
| `type` | NOT NULL | meeting room / lecture room / studio / workshop room |
| `requires_approval` | NOT NULL | Boolean — whether this room requires special access approval |

#### EquipmentType
| Attribute | Type | Notes |
|---|---|---|
| `equipment_id` | PK | Primary key |
| `name` | NOT NULL | e.g. projector, whiteboard, microphone, video camera |

#### RoomEquipment *(linking table)*
| Attribute | Type | Notes |
|---|---|---|
| `room_id` | FK | → Room |
| `equipment_id` | FK | → EquipmentType |

#### Organization
| Attribute | Type | Notes |
|---|---|---|
| `organization_id` | PK | Primary key |
| `name` | NOT NULL | Student organization name |

#### Person
| Attribute | Type | Notes |
|---|---|---|
| `person_id` | PK | Primary key |
| `name` | NOT NULL | Full name |
| `email` | NOT NULL | Contact email — minimum personal data only |

#### BookingSeries *(the planning intent for recurring bookings)*
| Attribute | Type | Notes |
|---|---|---|
| `series_id` | PK | Primary key |
| `room_id` | FK | → Room |
| `organization_id` | FK | → Organization |
| `created_by` | FK | → Person |
| `recurrence_rule` | NOT NULL | e.g. "weekly", "biweekly" |
| `series_start_date` | NOT NULL | First occurrence date |
| `series_end_date` | NOT NULL | Last occurrence date |
| `day_of_week` | NOT NULL | e.g. "Wednesday" |
| `start_time` | NOT NULL | Time of day the slot starts |
| `end_time` | NOT NULL | Time of day the slot ends |

> **Why this table exists:** The case explicitly requires that a recurring booking be treatable *"both as a single planning intent and as a series of individual occurrences."* `BookingSeries` stores that intent. Without it, there is no single fact in the database representing "the organization has booked Wednesday evenings." The pattern fields (`recurrence_rule`, `day_of_week`, `start_time`, `end_time`) belong here because they describe the original intent, not any individual occurrence.

#### Booking *(one time slot — standalone or one occurrence of a series)*
| Attribute | Type | Notes |
|---|---|---|
| `booking_id` | PK | Primary key |
| `room_id` | FK | → Room |
| `organization_id` | FK | → Organization |
| `created_by` | FK | → Person |
| `start_datetime` | NOT NULL | Start of the booking slot |
| `end_datetime` | NOT NULL | End of the booking slot |
| `status` | NOT NULL | pending / confirmed / cancelled / rejected |
| `series_id` | FK, nullable | → BookingSeries; NULL if standalone booking |
| `created_at` | NOT NULL | Timestamp when the booking was created — needed for reporting and auditing |
| `cancelled_at` | nullable | Timestamp of cancellation; NULL if not cancelled |
| `cancellation_reason` | nullable | Short free text; NULL if not cancelled |
| `requires_approval` | NOT NULL | Snapshot of `Room.requires_approval` at booking creation time |
| `approval_granted` | nullable | NULL if approval not required or not yet decided; TRUE if approved; FALSE if rejected |

> **Why `requires_approval` appears on both Room and Booking:** `Room.requires_approval` reflects the room's current policy. `Booking.requires_approval` is a snapshot taken at booking creation time. If the room's policy changes later, historical bookings are not affected. This is a justified denormalization, noted in the design-quality review.
>
> **Reading approval state:**
>
> | `requires_approval` | `approval_granted` | Meaning |
> |---|---|---|
> | FALSE | NULL | No approval needed |
> | TRUE | NULL | Pending — waiting for approval decision |
> | TRUE | TRUE | Approved |
> | TRUE | FALSE | Rejected |

---

## 2. Candidate Relationships

| From | Relationship | To | Cardinality | Notes |
|---|---|---|---|---|
| Building | contains | Room | 1 to many | A room belongs to exactly one building |
| Room | has | EquipmentType | many to many | Via `RoomEquipment` linking table |
| Person | creates | Booking | 1 to many | Minimal personal data stored |
| Person | creates | BookingSeries | 1 to many | Same person model used for series creation |
| Organization | associated with | Booking | 1 to many | Organization linked via FK |
| Organization | associated with | BookingSeries | 1 to many | Organization linked via FK |
| Room | is booked by | Booking | 1 to many | A booking covers exactly one room |
| Room | is target of | BookingSeries | 1 to many | A series targets one room |
| BookingSeries | consists of | Booking | 1 to many | A standalone booking has `series_id = NULL` |

---

## 3. Key Assumptions

1. **Equipment is modeled as types, not physical assets.** A room either has a projector or does not. Serial numbers and individual item tracking are out of scope.
2. **A standalone booking and a recurring occurrence share the same `Booking` table.** A standalone booking simply has `series_id = NULL`.
3. **`requires_approval` is snapshotted onto `Booking` at creation time.** This ensures historical bookings are not affected if a room's approval policy changes later.
4. **`approval_granted` on `Booking` covers both the "required" and "outcome" states** via a nullable boolean. No separate approval table, no approver identity, no workflow stages — the case only asks whether approval was required and whether it was granted.
5. **Organization is a separate entity**, not just a name string on the booking. This makes reporting on organizations clean and consistent.
6. **Person stores name and email only.** This is the minimum needed to manage bookings responsibly, as stated in the case.
7. **Double-booking is prevented** — a room cannot have two confirmed bookings with overlapping time slots. This is enforced at the schema or application level.
8. **Recurrence is stored as a descriptive rule string and date range** (e.g. `"weekly"`, start date, end date, day of week). The database does not parse or enforce the rule — it is descriptive only.
9. **`created_at` is recorded on every Booking** to support reporting (e.g. bookings made per month) and auditing.

---

## 4. Ambiguities and Chosen Interpretations

| Ambiguity | Chosen Interpretation |
|---|---|
| Is equipment a specific physical item or a type? | Equipment type per room. No serial numbers or individual asset tracking. |
| Does a recurring booking need its own table? | Yes — `BookingSeries` stores the planning intent; individual `Booking` rows are the occurrences. Required explicitly by the case description. |
| What personal data is stored about the person creating a booking? | Name and contact email only. |
| Can the same room be double-booked? | No. Enforced as a constraint on confirmed bookings. |
| What does "approval" mean in practice — workflow, approver identity? | We store only `requires_approval` (snapshot boolean) and `approval_granted` (nullable boolean). No approver identity or multi-step workflow. |
| Can a cancellation reason contain personal information? | Possibly. We store it as a short optional free-text field and flag it as a privacy risk in the design-quality review. |
| Is recurrence pattern always weekly, or flexible? | We store a `recurrence_rule` string (e.g. `"weekly"`, `"biweekly"`) and a date range. The design does not enforce or parse the rule. |
| Is organization a separate entity or just a name string? | Separate entity with its own table, to support clean reporting by organization. |
| Should `requires_approval` live only on Room or also on Booking? | Both — `Room.requires_approval` is the current policy; `Booking.requires_approval` is a snapshot at creation time. Justified denormalization. |

---

## 5. Likely Application Queries

These are the queries the schema must be able to answer. All must be traceable through the conceptual model.

| ID | Query | Source |
|---|---|---|
| Q1 | How many bookings has each room had? | Case description |
| Q2 | Which organizations use the service most? | Case description |
| Q3 | Which rooms are most heavily used (by total hours booked)? | Case description |
| Q4 | Which equipment types appear most often in booked rooms? | Case description |
| Q5 | How many bookings were cancelled? | Case description |
| Q6 | Which bookings required approval, and was it granted? | Case description |
| Q7 | List all occurrences of a given booking series | Derived from recurring booking requirement |
| Q8 | Which bookings were made by a given organization within a date range? | Derived from reporting requirement |
