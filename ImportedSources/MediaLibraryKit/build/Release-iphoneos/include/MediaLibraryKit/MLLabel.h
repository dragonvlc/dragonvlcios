/*****************************************************************************
 * MLLabel.h
 * Lunettes
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2013 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import <CoreData/CoreData.h>

@class MLFile;

@interface MLLabel :  NSManagedObject
{
}
+ (NSArray *)allLabels;
- (NSArray *)sortedFolderItems;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* files;

@end


@interface MLLabel (CoreDataGeneratedAccessors)
- (void)addFilesObject:(MLFile *)value;
- (void)removeFilesObject:(MLFile *)value;
- (void)addFiles:(NSSet *)value;
- (void)removeFiles:(NSSet *)value;


@end
