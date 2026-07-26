import { Injectable, NotFoundException } from '@nestjs/common';
import notes from './notes.json';

@Injectable()
export class NotesService {
  findAll() {
    return [...notes].sort((a, b) => b.id - a.id);
  }

  findOne(id: number) {
    const note = notes.find((note) => note.id === id);

    if (!note) {
      throw new NotFoundException('Note not found');
    }

    return note.long_desc;
  }
}