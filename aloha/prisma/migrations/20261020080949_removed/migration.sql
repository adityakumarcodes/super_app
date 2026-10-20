/*
  Warnings:

  - You are about to drop the column `description` on the `notes_page` table. All the data in the column will be lost.
  - You are about to drop the column `editorVersion` on the `notes_page` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "notes_page" DROP COLUMN "description",
DROP COLUMN "editorVersion";
