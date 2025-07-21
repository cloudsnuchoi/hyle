import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

/*== STEP 1 ===============================================================
The section below creates a Todo database table with a "content" field. Try
adding a new "isDone" field as a boolean. The authorization rule below
specifies that any unauthenticated user can "create", "read", "update", 
and "delete" any "Todo" records.
=========================================================================*/
const schema = a.schema({
  User: a
    .model({
      email: a.string().required(),
      name: a.string().required(),
      learningType: a.string(),
      gradeLevel: a.string(),
      focusAreas: a.string().array(),
      preferences: a.json(),
      learningProfile: a.json(),
      premiumTier: a.enum(['FREE', 'BASIC', 'PRO', 'UNLIMITED']),
      studySessions: a.hasMany('StudySession', 'userId'),
      learningGoals: a.hasMany('LearningGoal', 'userId'),
      flashCards: a.hasMany('FlashCard', 'userId'),
    })
    .authorization((allow) => [allow.owner()]),

  StudySession: a
    .model({
      userId: a.id().required(),
      user: a.belongsTo('User', 'userId'),
      startTime: a.datetime().required(),
      endTime: a.datetime(),
      duration: a.integer(),
      subject: a.string(),
      notes: a.string(),
      productivity: a.integer(),
      focusScore: a.float(),
    })
    .authorization((allow) => [allow.owner()]),

  LearningGoal: a
    .model({
      userId: a.id().required(),
      user: a.belongsTo('User', 'userId'),
      title: a.string().required(),
      description: a.string(),
      targetDate: a.date(),
      progress: a.float(),
      status: a.enum(['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED']),
      milestones: a.json(),
    })
    .authorization((allow) => [allow.owner()]),

  FlashCard: a
    .model({
      userId: a.id().required(),
      user: a.belongsTo('User', 'userId'),
      question: a.string().required(),
      answer: a.string().required(),
      category: a.string(),
      difficulty: a.enum(['EASY', 'MEDIUM', 'HARD']),
      lastReviewDate: a.datetime(),
      nextReviewDate: a.datetime(),
      reviewCount: a.integer(),
      correctCount: a.integer(),
    })
    .authorization((allow) => [allow.owner()]),

  Mission: a
    .model({
      title: a.string().required(),
      description: a.string(),
      category: a.string(),
      points: a.integer(),
      difficulty: a.enum(['EASY', 'MEDIUM', 'HARD']),
      requirements: a.json(),
      rewards: a.json(),
      isActive: a.boolean(),
    })
    .authorization((allow) => [allow.authenticated().to(['read']), allow.groups(['admin'])]),

  Todo: a
    .model({
      content: a.string().required(),
      isDone: a.boolean(),
      priority: a.enum(['LOW', 'MEDIUM', 'HIGH']),
      dueDate: a.datetime(),
      userId: a.id(),
    })
    .authorization((allow) => [allow.owner()]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'identityPool',
  },
});

/*== STEP 2 ===============================================================
Go to your frontend source code. From your client-side code, generate a
Data client to make CRUDL requests to your table. (THIS SNIPPET WILL ONLY
WORK IN THE FRONTEND CODE FILE.)

Using JavaScript or Next.js React Server Components, Middleware, Server 
Actions or Pages Router? Review how to generate Data clients for those use
cases: https://docs.amplify.aws/gen2/build-a-backend/data/connect-to-API/
=========================================================================*/

/*
"use client"
import { generateClient } from "aws-amplify/data";
import type { Schema } from "@/amplify/data/resource";

const client = generateClient<Schema>() // use this Data client for CRUDL requests
*/

/*== STEP 3 ===============================================================
Fetch records from the database and use them in your frontend component.
(THIS SNIPPET WILL ONLY WORK IN THE FRONTEND CODE FILE.)
=========================================================================*/

/* For example, in a React component, you can use this snippet in your
  function's RETURN statement */
// const { data: todos } = await client.models.Todo.list()

// return <ul>{todos.map(todo => <li key={todo.id}>{todo.content}</li>)}</ul>
