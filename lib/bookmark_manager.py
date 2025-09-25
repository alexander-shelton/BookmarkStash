#!/usr/bin/env python3
"""
Simple Command-Line Bookmark Manager

A lightweight bookmark manager that stores URLs, titles, and tags in a JSON file.
Supports adding, listing, searching, and deleting bookmarks via command-line interface.
"""

import argparse
import json
import os
import sys
from urllib.parse import urlparse
from typing import List, Dict, Optional

bookmarks_path = os.path.join(os.path.expanduser("~"), ".bookmarks.json")


class BookmarkManager:
    """Main class for managing bookmarks with JSON file persistence."""

    def __init__(self, data_file: str = bookmarks_path):
        """Initialize the bookmark manager with specified data file."""
        self.data_file = data_file
        self.bookmarks = self._load_bookmarks()

    def _load_bookmarks(self) -> List[Dict[str, str]]:
        """Load bookmarks from JSON file or create empty list if file doesn't exist."""
        if not os.path.exists(self.data_file):
            return []

        try:
            with open(self.data_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            print(f"Error loading bookmarks file: {e}")
            print("Starting with empty bookmark collection.")
            return []

    def _save_bookmarks(self) -> bool:
        """Save bookmarks to JSON file. Returns True on success, False on failure."""
        try:
            with open(self.data_file, "w", encoding="utf-8") as f:
                json.dump(self.bookmarks, f, indent=2, ensure_ascii=False)
            return True
        except IOError as e:
            print(f"Error saving bookmarks: {e}")
            return False

    def _validate_url(self, url: str) -> bool:
        """Validate URL format using urllib.parse."""
        try:
            result = urlparse(url)
            return all([result.scheme, result.netloc])
        except Exception:
            return False

    def _find_bookmark_by_url(self, url: str) -> Optional[int]:
        """Find bookmark index by URL. Returns index or None if not found."""
        for i, bookmark in enumerate(self.bookmarks):
            if bookmark["url"].lower() == url.lower():
                return i
        return None

    def _find_bookmarks_by_title(self, title: str) -> List[int]:
        """Find bookmark indices by title (case-insensitive). Returns list of indices."""
        indices = []
        title_lower = title.lower()
        for i, bookmark in enumerate(self.bookmarks):
            if bookmark["title"].lower() == title_lower:
                indices.append(i)
        return indices

    def add_bookmark(self, url: str, title: str, tag: str) -> bool:
        """Add a new bookmark. Returns True on success, False on failure."""
        # Validate URL
        if not self._validate_url(url):
            print(f"Error: Invalid URL format: {url}")
            return False

        # Check if URL already exists
        if self._find_bookmark_by_url(url) is not None:
            print(f"Error: Bookmark with URL '{url}' already exists.")
            return False

        # Validate required fields
        if not title.strip():
            print("Error: Title cannot be empty.")
            return False

        if not tag.strip():
            print("Error: Tag cannot be empty.")
            return False

        # Add bookmark
        new_bookmark = {"url": url.strip(), "title": title.strip(), "tag": tag.strip()}

        self.bookmarks.append(new_bookmark)

        if self._save_bookmarks():
            print("✓ Bookmark added successfully:")
            print(f"  Title: {new_bookmark['title']}")
            print(f"  URL: {new_bookmark['url']}")
            print(f"  Tag: {new_bookmark['tag']}")
            return True
        else:
            # Remove the bookmark if save failed
            self.bookmarks.pop()
            return False

    def list_bookmarks(
        self, filter_type: Optional[str] = None, filter_value: Optional[str] = None
    ) -> None:
        """Display bookmarks, optionally filtered by title or tag."""
        bookmarks_to_show = self.bookmarks

        # Apply filter if specified
        if filter_type and filter_value:
            bookmarks_to_show = []
            filter_value_lower = filter_value.lower()

            for bookmark in self.bookmarks:
                if (
                    filter_type == "title"
                    and bookmark["title"].lower() == filter_value_lower
                ):
                    bookmarks_to_show.append(bookmark)
                elif (
                    filter_type == "tag"
                    and bookmark["tag"].lower() == filter_value_lower
                ):
                    bookmarks_to_show.append(bookmark)

        if not bookmarks_to_show:
            if filter_type:
                print(f"No bookmarks found with {filter_type}: '{filter_value}'")
            else:
                print("No bookmarks found.")
            return

        # Display header
        if filter_type:
            print(
                f"\n📚 Found {len(bookmarks_to_show)} bookmark(s) with {filter_type}: '{filter_value}'"
            )
        else:
            print(f"\n📚 Found {len(bookmarks_to_show)} bookmark(s):")
        print("-" * 80)

        for i, bookmark in enumerate(bookmarks_to_show, 1):
            print(f"{i:2d}. {bookmark['title']}")
            print(f"    URL: {bookmark['url']}")
            print(f"    Tag: {bookmark['tag']}")
            print()

    def search_bookmarks(self, query: str, search_type: str = "title") -> None:
        """Search bookmarks by title or tag (case-insensitive)."""
        if not query.strip():
            print("Error: Search query cannot be empty.")
            return

        query_lower = query.lower()
        tag_matches = []

        if search_type == "title":
            for bookmark in self.bookmarks:
                if query_lower in bookmark["title"].lower():
                    print(bookmark["url"])
                    return bookmark["url"]
        elif search_type == "tag":
            for bookmark in self.bookmarks:
                if query_lower in bookmark["tag"].lower():
                    tag_matches.append(bookmark["title"])
            for tag in tag_matches:
                print(tag)
            return tag_matches

        return None

    def delete_bookmark(self, identifier: str, delete_type: str = "url") -> bool:
        """Delete bookmark by URL or title. Returns True on success, False on failure."""
        if not identifier.strip():
            print(f"Error: {delete_type.capitalize()} cannot be empty.")
            return False

        # Find bookmarks to delete
        bookmarks_to_remove = []
        if delete_type == "url":
            index = self._find_bookmark_by_url(identifier)
            if index is not None:
                bookmarks_to_remove.append(self.bookmarks[index])
        elif delete_type == "title":
            indices = self._find_bookmarks_by_title(identifier)
            for idx in indices:
                bookmarks_to_remove.append(self.bookmarks[idx])

        if not bookmarks_to_remove:
            print(f"Error: No bookmark found with {delete_type}: '{identifier}'")
            return False

        # If multiple matches for title, show them and ask for confirmation
        if delete_type == "title" and len(bookmarks_to_remove) > 1:
            print(
                f"Found {len(bookmarks_to_remove)} bookmarks with title '{identifier}':"
            )
            for i, bookmark in enumerate(bookmarks_to_remove, 1):
                print(f"{i}. URL: {bookmark['url']}, Tag: {bookmark['tag']}")
            print("All matching bookmarks will be deleted.")

        # Create a new list of bookmarks excluding the ones to be deleted
        new_bookmarks = []
        deleted_count = 0
        deleted_bookmarks_info = []  # To store info for printing success message

        for bookmark in self.bookmarks:
            is_deleted = False
            for b_to_remove in bookmarks_to_remove:
                # Compare based on URL for uniqueness
                if bookmark["url"].lower() == b_to_remove["url"].lower():
                    is_deleted = True
                    deleted_count += 1
                    deleted_bookmarks_info.append(bookmark)
                    break
            if not is_deleted:
                new_bookmarks.append(bookmark)

        # Store current bookmarks in case of save failure
        original_bookmarks = self.bookmarks

        # Attempt to save the new list
        self.bookmarks = new_bookmarks
        if self._save_bookmarks():
            print(f"✓ Deleted {deleted_count} bookmark(s):")
            for bookmark in deleted_bookmarks_info:
                print(f"  - {bookmark['title']} ({bookmark['url']})")
            return True
        else:
            # Revert to original bookmarks if save failed
            self.bookmarks = original_bookmarks
            print("Error: Failed to save changes. Bookmarks were not deleted.")
            return False

    def list_tags(self) -> None:
        """Display all unique tags in the bookmark collection."""
        if not self.bookmarks:
            print("No bookmarks found.")
            return

        tags = sorted(set(bookmark["tag"] for bookmark in self.bookmarks))

        for tag in tags:
            print(f"{tag}")

    def list_titles(self) -> None:
        """Display all unique titles in the bookmark collection."""
        if not self.bookmarks:
            print("No bookmarks found.")
            return

        titles = sorted(set(bookmark["title"] for bookmark in self.bookmarks))

        for title in titles:
            print(f"{title}")

    def show_stats(self) -> None:
        """Display statistics about the bookmark collection."""
        if not self.bookmarks:
            print("No bookmarks found.")
            return

        # Count unique tags
        tags = set(bookmark["tag"] for bookmark in self.bookmarks)

        print("\n📊 Bookmark Statistics:")
        print(f"  Total bookmarks: {len(self.bookmarks)}")
        print(f"  Unique tags: {len(tags)}")
        print(f"  Data file: {self.data_file}")

        if tags:
            print(f"  Tags: {', '.join(sorted(tags))}")


def create_parser() -> argparse.ArgumentParser:
    """Create and configure the command-line argument parser."""
    parser = argparse.ArgumentParser(
        description="Simple Command-Line Bookmark Manager",
        epilog="Examples:\n"
        "  %(prog)s add https://example.com 'Example Site' tech\n"
        "  %(prog)s list\n"
        "  %(prog)s list --title 'GitHub'\n"
        "  %(prog)s list --tag development\n"
        "  %(prog)s tags\n"
        "  %(prog)s titles\n"
        "  %(prog)s search python\n"
        "  %(prog)s search --tag web\n"
        "  %(prog)s delete https://example.com\n"
        "  %(prog)s delete --title 'Example Site'",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    # Add bookmark command
    add_parser = subparsers.add_parser("add", help="Add a new bookmark")
    add_parser.add_argument("url", help="URL of the bookmark")
    add_parser.add_argument("title", help="Title of the bookmark")
    add_parser.add_argument("tag", help="Tag for the bookmark")

    # List bookmarks command
    list_parser = subparsers.add_parser("list", help="List all bookmarks")
    list_parser.add_argument("--title", help="Filter bookmarks by exact title")
    list_parser.add_argument("--tag", help="Filter bookmarks by exact tag")

    # Search bookmarks command
    search_parser = subparsers.add_parser("search", help="Search bookmarks")
    search_parser.add_argument("query", help="Search query")
    search_parser.add_argument(
        "--tag", action="store_true", help="Search by tag instead of title"
    )

    # Delete bookmark command
    delete_parser = subparsers.add_parser("delete", help="Delete a bookmark")
    delete_group = delete_parser.add_mutually_exclusive_group(required=True)
    delete_group.add_argument("--url", help="Delete bookmark by URL")
    delete_group.add_argument("--title", help="Delete bookmark by title")

    # List tags command
    subparsers.add_parser("tags", help="List all unique tags")

    # List titles command
    subparsers.add_parser("titles", help="List all unique titles")

    # Statistics command
    subparsers.add_parser("stats", help="Show bookmark statistics")

    # Data file option
    parser.add_argument(
        "--file",
        default="bookmarks.json",
        help="Bookmark data file (default: bookmarks.json)",
    )

    return parser


def main() -> None:
    """Main entry point for the bookmark manager."""
    parser = create_parser()
    args = parser.parse_args()

    # Show help if no command provided
    if not args.command:
        parser.print_help()
        return

    # Initialize bookmark manager
    manager = BookmarkManager(bookmarks_path)

    try:
        # Execute the requested command
        if args.command == "add":
            manager.add_bookmark(args.url, args.title, args.tag)

        elif args.command == "list":
            # Handle filtering options
            if args.title:
                manager.list_bookmarks("title", args.title)
            elif args.tag:
                manager.list_bookmarks("tag", args.tag)
            else:
                manager.list_bookmarks()

        elif args.command == "search":
            search_type = "tag" if args.tag else "title"
            manager.search_bookmarks(args.query, search_type)

        elif args.command == "delete":
            if args.url:
                manager.delete_bookmark(args.url, "url")
            elif args.title:
                manager.delete_bookmark(args.title, "title")

        elif args.command == "tags":
            manager.list_tags()

        elif args.command == "titles":
            manager.list_titles()

        elif args.command == "stats":
            manager.show_stats()

    except KeyboardInterrupt:
        print("\n\nOperation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
