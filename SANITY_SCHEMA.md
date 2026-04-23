# Sanity CMS Schema for Mimi App

To enable real-time synchronization, you need to create these schemas in your Sanity Studio.

## 1. Shared Note (`sharedNote.ts`)
Used for synced notes, thoughts, and shared letters.

```typescript
export default {
  name: 'sharedNote',
  title: 'Shared Note',
  type: 'document',
  fields: [
    {
      name: 'title',
      title: 'Title',
      type: 'string',
    },
    {
      name: 'content',
      title: 'Content',
      type: 'text',
    },
    {
      name: 'author',
      title: 'Author',
      type: 'string',
      options: {
        list: ['Mimi', 'Greg'], // Customize as needed
      },
    },
    {
      name: 'date',
      title: 'Date',
      type: 'datetime',
    },
  ],
};
```

## 2. Watchlist Movie (`watchlistMovie.ts`)
Track movies and shows to watch together.

```typescript
export default {
  name: 'watchlistMovie',
  title: 'Watchlist Movie',
  type: 'document',
  fields: [
    {
      name: 'title',
      title: 'Movie Title',
      type: 'string',
    },
    {
      name: 'imageUrl',
      title: 'Poster Image URL',
      type: 'url',
    },
    {
      name: 'isWatched',
      title: 'Has been watched?',
      type: 'boolean',
      initialValue: false,
    },
    {
      name: 'rating',
      title: 'Our Rating',
      type: 'number',
      validation: (Rule) => Rule.min(0).max(5),
    },
  ],
};
```

## 3. Shared Image (`sharedImage.ts`)
A shared gallery of moments.

```typescript
export default {
  name: 'sharedImage',
  title: 'Shared Image',
  type: 'document',
  fields: [
    {
      name: 'caption',
      title: 'Caption',
      type: 'string',
    },
    {
      name: 'image',
      title: 'Image',
      type: 'image',
      options: {
        hotspot: true,
      },
    },
    {
      name: 'timestamp',
      title: 'Timestamp',
      type: 'datetime',
    },
  ],
};
```

## 4. How to use
1. Copy these files into your Sanity Studio's `schemaTypes` folder.
2. Register them in `schemaTypes/index.ts`.
3. Deploy your Sanity Studio: `npx sanity deploy`.
4. Copy your **Project ID** and **Token** (with Write permissions) into `lib/data/sanity_repository.dart`.
