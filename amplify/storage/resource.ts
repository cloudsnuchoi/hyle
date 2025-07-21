import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
  name: 'hyleStorage',
  access: (allow) => ({
    'profile-pictures/*': [
      allow.guest.to(['read']),
      allow.entity('identity').to(['read', 'write', 'delete'])
    ],
    'study-materials/*': [
      allow.authenticated.to(['read']),
      allow.entity('identity').to(['read', 'write', 'delete'])
    ],
    'flashcard-images/*': [
      allow.authenticated.to(['read']),
      allow.entity('identity').to(['read', 'write', 'delete'])
    ],
  })
});